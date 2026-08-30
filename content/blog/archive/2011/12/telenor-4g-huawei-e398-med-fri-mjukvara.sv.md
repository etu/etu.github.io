---
title: 'Telenor 4G, Huawei E398 med fri mjukvara'
date: '2011-12-06T12:00:00+0100'
url: /index.php/2011/12/telenor-4g-huawei-e398-med-fri-mjukvara/
draft: true
---

Har förflyttat mig ner till Helsingborg, detta resulterade i att jag inte har något fast Internet hemma, så jag införskaffade mig ett 4G från Telenor.

Jag valde Telenor på grund av tre anledningar…

1.  Modemet visade förhoppningar att köra i Linux
2.  De har 4G täckning där jag bor med goda marginaler på yta
3.  Telenor är den enda leverantören som säljer abonnemang till privatpersoner *“utan”* begränsning

Till en början så identifierar sig modemet som

*12d1:1505*, men med lite [modeswitch](http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=669&sid=c9579fe9d25c8377eb8f572e657b751a "modeswitch") på den så kommer den identifiera sig på följande vis:

    Bus 002 Device 004: ID 12d1:1506 Huawei Technologies Co., Ltd.

Och som den Gentoo användare måste jag sätta upp min kärna för att slå de moduler och drivrutiner jag behöver för all hårdvara, så jag tänkte lista de moduler jag behöver för få igång modemet.

Dessa options använder jag i min linux 3.0.4 kärna:

    Device Drivers --->
      [*] Network device support --->
        <*> PPP (point-to-point protocol) support
        <*>   PPP support for async serial ports
      [*] USB support --->
        <*> USB Serial Converter support --->
          [*] USB Serial Console device support
          [*] USB Generic Serial Driver
          <*> USB driver for GSM and CDMA modems

Efter att man modeswitchat enheten och har de kärnmoduler som krävs så skall det dyka upp en enhet som heter */dev/ttyUSB0*.

Sedan så behöver du *ppp*, *wvdial* samt lite konfiguration.

Wvdial kan generera en helt okej grund till att konfigurera det som krävs för att det ska fungera.

    $ sudo wvdialconf

Min konfigruation wvdial ser ut såhär: (fil: */etc/wvdial.conf*)

    [Dialer Defaults]
    ;Init = ATZ0
    Init1 = ATZ
    Init2 = ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0
    Init3 = AT+CGDCONT=1,"IP","internet.telenor.se","",0,0
    Phone = *99#
    Modem Type = Analog Modem
    Baud = 9600
    Modem = /dev/ttyUSB0
    ISDN = 0
    Username = 4G
    Password = 4G
    Stupid Mode = 1

Username och Password verkar inte spela roll, Stupid Mode gjorde så att saker började fungera.

Jag har hitils lyckats nå 2Mb/s stabilt i nerladdning, teoretiskt sett ska jag kunna nå 8Mb/s, vet inte om jag skickar rätt APN eller ej med mina AT kommandon, om det är någon som har tips så får de gärna skriva en kommentar om det. Men så långt fungerar det och det känns som en bra början.
