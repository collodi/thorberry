$1 == "BSS" {
    if (NR > 2 && SSID != "" && index(SSID, "\x") == 0)
        printf "%s,%s,%s\n", SSID, sig, enc;

    enc = "Open";
}
$1 == "SSID:" {
    SSID = $2;
}
$1 == "signal:" {
    sig = $2 " " $3;
}
$1 == "WPA:" {
    enc = "WPA";
}
$1 == "WPS:" {
    enc = "WPA";
}

END {
    if (SSID != "" && index(SSID, "\x") == 0)
        printf "%s,%s,%s\n", SSID, sig, enc;
}
