---
title: 'Windows XP – Rond 2'
date: '2010-03-02T12:00:00+0100'
url: /index.php/2010/03/windows-xp-rond-2/
draft: true
tags: [Mjukvara, Lidande, Windows]
---

Efter mitt första bråk med Windows så kunde jag ju inte ge upp, jag kunde inte släppa det. Jag kan inte förlora mot något som är så dåligt. Här kan du läsa om [mitt första windowsbråk](/index.php/2010/02/windows-xp-inte-sa-bra-som-manga-tror/ "mitt första windowsbråk"), som slutade med att jag var mer irriterad än innan jag försökte.

Men, i fredags så gav jag mig på att göra om installationen från början, för att ha en ren installation, utan att ha labbat massor i den. Denna gång gick det mycket snabbare, för det första så visste jag exakt hur man genomför Windows XP installationer från USB-Sticka, installerade alla drivrutiner, uppgraderade, lade till i domänen och packade ihop till en imagefil.

Installerade alla program som ska finnas med i grundinstallationerna, och packade ihop till en ny imagefil. Sedan så var det bara en sak kvar, igen… Roaming Profiles… Jag har aldrig sysslat med detta tidigare, men det var väldigt oväntat enkelt faktiskt. Det var redan klart.

Det misslyckades enbart för att jag inte hade en mapp som hette .winprofile i min hemkatalog, enbart därför kunde den inte hämta min profil och det är väl rimligt. Men istället för att ge mig en temporär profil på datorn så vore det ännu mera rimligt att skapa katalogen, den ligger i skrivbart område för min användare.

Jag försökte till och med skapa katalogen själv, i windows. Det gick förstås inte. För att all text före en punkt är ett namn, och allt efter är en filtyp. Så en katalog som heter .winprofile har inget namn, filändelsen som det så fancy kallas är en del av filnamnet. Så läsningen blev ännu en gång att starta upp ett linux-system och skapa katalogen, windows kunde helt enkelt inte.

Windows tenderar att kunna skapa alla kataloger som användaren ska ha för att kunna vara inloggad i systemet, men… inte kan den skapa katalogen där profilen ska ligga om den är Roaming och ligger i nätverket. Bah… Så enkelt, och det ska ändå vara så svårt.

Ännu en gång har jag lärt mig om hur illa Windows kan vara att hantera, ännu en gång är jag inte förvånad.

Likaså skrivarhanteringen för skrivare på nätverk i Windows är fantastiska, man skapar en virtuell port av typen IP som bryggar anslutningen över ett nätverkskort till en IP-Adress, där den hittar skrivaren, precis som att det vore en lokal skrivare. Fantastiskt operativ det där som Microsoft tillverkar… Jag har lärt mig för mycket om det för att inte kunna tycka bra om det längre.

Nu efter rond 2, så har jag till slut lyckats få ett fungerande system som fungerar som det är tänkt i nätverket, på ett sätt Windows FLP inte kunde åstadkomma.
