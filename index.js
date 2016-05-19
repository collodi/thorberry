var app = require('express')();
var cookieparse = require('cookie-parser');
var bodyparse = require('body-parser');
var child_process = require('child_process');
var crypto = require('crypto');
var exec = child_process.exec;
var spawn = child_process.spawn;
var upload = require('multer')({ path: '/tmp/' });
var fs = require('fs');
var process = require('process');

// change working directory to index.js location
process.chdir(__filename.substring(0, __filename.lastIndexOf('/') + 1));

// global vars
var dirs = { 'log': './../logs/', 'conf': './../confs/' };
var status_colors = ['green', 'orange', 'yellow', 'red'];
var sessions = [];

app.set('views', './views');
app.set('view engine', 'jade');

app.use(cookieparse());

function gen_session() {
	var t_sessionid = '';
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	for( var i=0; i < 20; i++ )
		t_sessionid += chars.charAt(Math.floor(Math.random() * chars.length));
	return t_sessionid;
}

app.all('*', function(req, res, next) {
	res.header('X-Powered-By', 'Thorberry');
	next();
});

app.post('/', bodyparse.urlencoded({ extended: true }), function(req, res, next) {
	fs.readFile('/home/pi/shadow', function(err, data) {
		if (err) {
			res.end("Error fetching password info!");
		} else {
			var sid = req.cookies.sessionid;
			var hashed = crypto.createHmac('sha256', req.body.password).digest('hex');
			var comb = req.body.username + ":" + hashed;
			data.toString().split('\n').some(function(e) {
				if (e.indexOf(comb) === 0) {
					sessions[sid] = { username: req.body.username, level: e.split(':')[2], logged_in: true};
					return true;
				}
			});

			if (sid in sessions && sessions[sid].logged_in)
				res.redirect('/');
			else
				res.render('index', { session: sessions[sid], res: res });
		}
	});
});

// check session
app.all('*', function(req, res, next) {
	var logged_out = false;
	var sessionid = req.cookies.sessionid;
	if (req.query.logout !== undefined && sessionid !== undefined && sessions[sessionid] !== undefined && sessions[sessionid].logged_in === true) {
		delete sessions[sessionid];
		res.clearCookie(sessionid);
		logged_out = true;
	}

	if (sessionid === undefined || sessions[sessionid] === undefined || logged_out) {
		sessionid = gen_session();
		sessions[sessionid] = { username: "", logged_in: false, level: 0 };
		res.cookie('sessionid', sessionid);
		res.render('index', { session: sessions[sessionid], res: res });
	} else {
		next();
	}
});

app.get('/', function(req, res, next) {
	var sid = req.cookies.sessionid;
	fs.readFile('./../last_checked.txt', function(err, data) {
		var json_data = JSON.parse(data);
		res.light = json_data['lightningalert'];
		res.light_color = status_colors[json_data['state']];
		res.last_time = json_data['localtime'];

		delete json_data['lightningalert'];
		delete json_data['state'];
		delete json_data['localtime'];

		if (err) {
			res.last_checked = "Error opening last_checked.txt!\n" + err;
		} else {
			res.last_checked = "";
			Object.keys(json_data).sort().forEach(function(k) {
				res.last_checked += k + ": " + json_data[k] + "\n";
			});
		}

		exec('ps aux | grep -E "python .+*thorlogger.py$" | wc -l', function(err, stdout, stderr) {
			if (err) {
				res.end("Error collecting Thorberry status!");
			} else {
				res.thorberry = stdout > 0 ? "Running" : "Down";
				res.thorberry_color = stdout > 0 ? "green" : "red";
				res.render('index', { title: 'Thorberry Homepage', session: sessions[sid], res: res });
			}
		});
	});
});

// views a log file
app.get('/log', function(req, res, next) {
	var log_file = dirs['log'] + req.query.p + '.log';
	fs.readFile(log_file, function(err, data) {
		if (err) {
			res.end("Error opening log file!");
		} else {
			res.setHeader('Content-Disposition', 'filename=' + req.query.p + '.log');
			res.end(data);
		}
	});
});

// privilege block
app.all('*', function(req, res, next) {
	var sid = req.cookies.sessionid;
	if (sessions[sid].level > 99 || req.query.t === "log") {
		next();
	} else {
		res.to = '/';
		res.msg = 'You are not worthy enough to do that. I\'m sending you back to home.';
		res.render('redirect', { session: sessions[sid], res: res });
	}
});

// output test
app.get('/lightest', function(req, res, next) {
	spawn('python /home/pi/www/files/pys/gpiotest.py', { stdio: 'ignore' });

	res.to = '/';
	res.msg = '5 seconds for each stage of warning. Redirecting you to the main page.';
	res.render('redirect', { session: sessions[sid], res: res });
});

// async serialized file filter
var async_files = function(i, path, files, suffix, callback) {
	fs.stat(path + files[i], function(err, stats) {
		if (!err && stats.isFile() && files[i].indexOf(suffix, files[i].length - suffix.length) !== -1)
			files[i] = files[i].substring(0, files[i++].lastIndexOf('.'));
		else
			files.splice(i, 1);

		if (i == files.length)
			callback(files);
		else
			async_files(i, path, files, suffix, callback);
	});
};

// shows list of files
app.get('/list', function(req, res, next) {
	var sid = req.cookies.sessionid;
	var dir = dirs[req.query.t];
	// delete (only logs)
	if (sessions[sid].level > 99 && req.query.t === "log" && req.query.del) {
		fs.unlink(dir + req.query.del + '.log', function (err) {
			if (err) {
				res.end("Error deleting log file!\n" + err);
			} else {
				res.to = '/list?t=log';
				res.msg = 'Log deleted successfully!';
				res.render('redirect', { session: sessions[sid], res: res });
			}
		});
	} else if (req.query.t in dirs) {
		fs.readdir(dir, function(err, files) {
			if (err) {
				res.end("Cannot read the directory!");
			} else {
				async_files(0, dir, files, req.query.t, function(data) {
					res.t = req.query.t;
					res.link = '/' + req.query.t + '?p=';
					if (res.t === "log") {
						res.del = true;
					}

					res.list = data;
					res.render('list', { title: 'Thorberry List - ' + req.query.t, session: sessions[sid], res: res });
				});
			}
		});
	} else {
		res.end("Not a valid filetype to list!");
	}
});

// view a conf file
app.get('/conf', function(req, res, next) {
	var sid = req.cookies.sessionid;
	var conf_file = dirs['conf'] + req.query.p + '.conf';
	fs.readFile(conf_file, function(err, data) {
		if (err) {
			res.end("Error opening configuration file!");
		} else {
			res.setHeader('Content-Disposition', 'filename=' + req.query.p + '.conf');
			res.appname = req.query.p;
			res.data = JSON.parse(data);
			res.render('conf', { session: sessions[sid], res: res });
		}
	});
});

// edit conf file
app.post('/conf', bodyparse.urlencoded({ extended: true }), function(req, res, next) {
	var sid = req.cookies.sessionid;
	var p = req.body.aPpnAme;
	delete req.body.aPpnAme;

	for (var k in req.body) {
		if (req.body[k].indexOf(',') !== -1)
			req.body[k] = req.body[k].split(',');
		else if (!isNaN(+req.body[k]))
			req.body[k] = +req.body[k];
	}

	var json_data = JSON.parse(JSON.stringify(req.body));
	fs.readFile(dirs['conf'] + p + '.conf', function(err, data) {
		if (err) {
			res.end("Error opening configuration file!");
		} else { // check key consistency
			var prev_data = JSON.parse(data);
			for (var k in prev_data) {
				if (!(k in json_data))
					json_data[k] = prev_data[k];
			}

			fs.writeFile(dirs['conf'] + p + '.conf', JSON.stringify(json_data), function(err) {
				if (err) {
					res.end("Error updating conf file!");
				} else {
					res.to = '/reset';
					res.msg = 'conf file updated successfully! Thorberry will restart in 5 seconds.';
					res.render('redirect', { session: sessions[sid], res: res });
				}
			});
		}
	});
});

/*
// upload new py file
app.post('/upload', upload.single('file'), function(req, res, next) {
	var sid = req.cookies.sessionid;
	var dir = dirs['py'];
	var filename = req.body.f + '.py';
	fs.stat(dir + filename, function(err, stats) {
		if (!err && stats.isFile()) {
			fs.writeFile(dir + filename, req.file.buffer, function(err) {
				if (err) {
					res.end("Error uploading file!");
				} else {
					res.to = '/list?t=py';
					res.msg = 'File upload successful!';
					res.render('redirect', { session: sessions[sid], res: res });
				}
			});
		} else {
			res.end("Illegal upload!");
		}
	});
});
*/

// wireless scan (raspi 3 only)
app.get('/wireless', function(req, res, next) {
	var sid = req.cookies.sessionid;
	exec('iw wlan0 link; ifconfig wlan0', function (err, stdout, stderr) {
		if (err) {
			res.end("Error getting wireless status!\n" + err);
		} else {
			res.status = stdout;
		        exec('iw wlan0 scan | awk -f /home/pi/www/scan.awk', function(err, stdout, stderr) {
        		        if (err) {
                		        res.end("Failed to scan wireless networks!\n" + err);
	                	} else {
        	                	var nets = stdout.split('\n');
					res.ssids = [];
					for (var i = 0; i < nets.length - 1; i++) {
						var infs = nets[i].split(',');
						res.ssids.push(infs);
					}

					res.render('wireless', { session: sessions[sid], res: res });
        		        }
	        	});
		}
	});
});

app.post('/wireless', bodyparse.urlencoded({ extended: true }), function(req, res, next) {
	var sid = req.cookies.sessionid;
	exec('ps aux | grep -E "wpa_supplicant.conf$" | awk \'{print $2 }\'', function (err, stdout, stderr) {
		if (err) {
			res.end("Failed to get pids of connected network!\n" + err);
		} else {
			var pids = stdout.split('\n');
			for (var i = 0; i < pids.length; i++) {
				if (pids[i].length == 0)
					pids.splice(i, 1);
			}

			if (pids.length > 0) {
				exec('kill -9 ' + pids.join(' '), function(err, stdout, stderr) {
					if (err)
						res.end("Failed to kill connected network!\n" + err);
				});
			}


			spawn('/home/pi/www/wpa_script', [req.body.ssid, req.body.psk], { stdio: 'ignore' });
			//spawn('/home/pi/www/wpa_script', [req.body.ssid, req.body.psk, req.body.address, req.body.subnet, req.body.gateway], { stdio: 'ignore' });

			res.to = '/wireless';
			//res.msg = 'The static IP might need a reboot to take effect. Check the connection status before reboot. You will be redirected to the wireless page now.';
			res.msg = 'The connection tried successfully. Check the connection status before reboot. You will be redirected to the wireless page now.';
			res.render('redirect', { session: sessions[sid], res: res });
		}
	});
});

// restart thorlogger
app.get('/reset', function(req, res, next) {
	var sid = req.cookies.sessionid;
	exec('ps aux | grep -E "python .+thorlogger.py$" | awk \'{ print $2 }\'', function(err, stdout, stderr) {
		if (err) {
			res.end("Failed to get pids of running Thorberry!\n" + err);
		} else {
			var pids = stdout.split('\n');
			for (var i = 0; i < pids.length; i++) {
				if (pids[i].length === 0)
					pids.splice(i, 1);
			}

			if (pids.length > 0) {
				exec('kill -9 ' + pids.join(' '), function(err, stdout, stderr) {
					if (err)
						res.end("Failed to kill running Thorberry!\n" + err);
				});
			}

			var thor = spawn('python', ['./files/pys/thorlogger.py'], { stdio: 'ignore', detached: true });
			thor.on('error', function (err) {
				thor = null;
				res.end("Failed to start new Thorberry process!");
			});

			if (thor != null) {
				thor.unref();

				res.to = '/';
				res.msg = 'Thorberry reset successful!';
				res.render('redirect', { session: sessions[sid], res: res });
			}
		}
	});
});

// change password page
app.get('/user', function(req, res, next) {
	var sid = req.cookies.sessionid;
	res.render('user', { session: sessions[sid], res: res });
});

// change password
app.post('/user', bodyparse.urlencoded({ extended: true }), function(req, res, next) {
	var sid = req.cookies.sessionid;
	fs.readFile('./files/shadow', function(err, data) {
		var newfile = [];
		var found = false;
		var hashed = crypto.createHmac('sha256', req.body.old_password).digest('hex');
		var new_hashed = crypto.createHmac('sha256', req.body.new_password).digest('hex');
		var lookfor = req.body.username + ":" + hashed;
		data.toString().split('\n').forEach(function(e, i, a) {
			if (e.indexOf(lookfor) === 0) {
				found = true;
				newfile.push(req.body.username + ":" + new_hashed + ":" + e.split(':')[2]);
			} else {
				newfile.push(e);
			}
		});

		if (found) {
			fs.writeFile('./files/shadow', newfile.join('\n'), function(err) {
				if (err) {
					res.end("Failed to update password!");
				} else {
					res.to = '/user';
					res.msg = 'User password changed successfully.';
					res.render('redirect', { session: sessions[sid], res: res });
				}
			});
		} else {
			res.to = '/user';
			res.msg = 'User is not registered!';
			res.render('redirect', { session: sessions[sid], res: res });
		}
	});
});

// restart raspberry pi
app.get('/restart', function(req, res, next) {
	res.end("Restarting Raspberry PI now! I will be back!");
	spawn('reboot', []).unref();
});

var server = app.listen(80);
