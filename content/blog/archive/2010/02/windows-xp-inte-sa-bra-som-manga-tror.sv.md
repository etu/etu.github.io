---
title: 'Windows XP – Inte så bra som många tror'
date: '2010-02-26T12:00:00+0100'
url: /index.php/2010/02/windows-xp-inte-sa-bra-som-manga-tror/
draft: true
tags: [Mjukvara, Lidande, Windows]
---

Windows XP, har gått från dåligt till okej. På 10 år. När det kom så var det inte så bra, men med åren så har det faktiskt blivit bättre. Det måste jag hålla med om.

Jag har själv ingen nyckel till det och kör det därmed inte själv. Men jag har kört det en del innan jag bytte till GNU/Linux.

Jag fick i alla fall som request på Proxxi att installera Windows XP Pro Corp, på en dator för att sedan packa ihop och deploya på de andra. Och jag sa, “javisst, hur svårt kan det vara? Jag har installerat XP förr”.

Det var lättare sagt än gjort, vi inledde det hela med att bränna en CD-Skiva, och försökte boota en dator på den. Och så sa den sitt gamla vanliga “Tryck på en tangent om du vill starta från skivan”, \*trycker\*, flimrar förbi lite text om maskinvarukonfigruation. Och svart, bara svart. Så långt kom vi.

Jag har provat med skiva och rensat disken från andra windows, ställt tillbaka klockan och allt möjligt så den inte tycker att man gör det för långt fram i tiden. Det kan inte ha varit något med SATA, som var vanligt att det felade ett tag. Eftersom vi kör på IDE. Vi har provat med olika skivor i olika läsare med olika releaser av XP, samma symptom i alla.

Igår kväll, vid 22 tiden så satte jag mig med detta igen, för att lösa problemet.

Jag lyckades efter ett någon timme ha ett installerat XP från USB-Minne med hjälp av wintoflash, men den bootade inte. Utan jag var tvungen att gå via USB-Minnet för att kunna boota den. Och det blev bara svart, inga felmeddelanden ingenting.

Efter mera letande på internet så fick jag reda på att “om du installerar XP från USB-Minne så kan det hända att den skriver konfigruationen till NTLDR fel”, så efter att jag ändrat det för hand så hade jag faktiskt ett Windows XP system som startade på egen hand. Detta tog 5 timmar, under denna tid så provade jag olika programvaror för att skapa USB-Minnen med XP. Den bästa är wintoflash, alla andra är dåliga. Som i att de inte fungerar.

Och om man får något av programmen att fungera så bör man vara beredd på att ändra boot.ini filen så den bootar från rätt partition efteråt. \*sucka\*, detta var inte uppenbart någonstans. Detta var bara jobbigt att få igång.

Och så installera program, ton med program, ett 20-30 brukar vi ha installerade som default. Och allt ska ställas in på rätt sätt, och detta ska inte få installera en toolbar, och detta ska installeras där. Denna mapp ska ligga här med de rättigheterna till denna grupp, osv… Inget roande direkt.

Och att lägga till en dator i en domän är ju också en spännande historia, det är ganska lätt så länge man har en fungerande windowsdomän. Och jag lyckades logga in i domänen och den körde logonscript och allt. Jättetrevligt.

Men där brast det på en punkt. Profilerna misslyckades, den kunde inte hämta profiler, och den kunde inte heller fixa roaming profiles med active directory.

Så nu när folk loggar in på den datorn får de en temporär profil utan möjligheter att lagra data lokalt över huvud taget. Sökningar på internet gav mig svar i form av “låt alla dina användare logga in och ut på datorn så deras filer skapas”, och det är typ “fuck no” det är ett par hundra stycken. Det vill jag inte ha.

Jag vill att profilerna lagras på servern och att användarens hemkatalog monteras mod samba. Eller i alla fall att man kan få en lokal profil om inte annat.

Jag hatar XP lite granna, det är jobbigt att installera på viss hårdvara, det hatar att bo på usbminnen för instalation och det är inte enkelt att göra relativt avancerade saker i även fast man kör en Pro Corporate version av det.

Nedlagda timmar: 18  
Sömn inatt: 4 timmar i förmiddags
