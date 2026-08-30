---
title: 'Min dag med InternetKrig – En Agents Krigsrapport – Del 1/?'
date: '2010-12-04T12:00:00+0100'
url: /index.php/2010/12/min-dag-med-internetkrig-del-1/
draft: true
tags: [Piratsaker, Telecomix, Warlog, Frihet, Internet, Lidande, Mjukvara, Öppenhet, Piratpartiet]
---

~~**English Version of this article might show up tomorrow.**~~  
**English version is now available [here!](/index.php/2010/12/my-day-with-internet-war-part-1/)**  
**Del två finns tillgänglig här: [Helgen – En Agents Krigsrapport – Del 2/?](/index.php/2010/12/helgen-en-agents-krigsrapport-del-2/)**

> Detta inlägg är en samling av mina tankar denna dag, och bör vara strukturerade i någorlunda kronologisk ordning för när saker faktiskt inträffade. Jag lär kunna ha glömt mycket, många länkar och så. Förlåt om någon känner sig missad, nu är jag trött men ville ha ner allt i text medan det är färskt i huvudet. Lång och extremt spännande dag.

Morgonen började med att jag vaknade av att telefonen ringde, telefonförsäljare. Men jag vaknade till och kunde inte somna om så jag startade upp datorn och gick in på IRC. Där jag upptäcker att de flesta kanaler jag hänger i var nästintill döda. Ett par personer från andra sidan Atlanten var vakna.

Sedan så ser jag twitterflödet rulla in, *wikileaks.org* är nere. Sägs det till en början, men jag börjar gräva i det, och finner ja: Det går inte att slå upp *wikileaks.org* längre. Så börjar vi gräva i vad de har för IP-adresser. Vi hittar en, den första är inte 100% vad vi sökte, där hittar vi wikileaks startsida, men kan inte komma åt cablegates som var intressant i fallet… Det råkade gå ut en tweet om att de fanns där som senare retweetades hela dagen. Detta var dock inte sant i detta skede, men är det nu.

Så får vi tag på en annan adress i ett helt annat nät, visar också startsidan och innehåller cablegates, det tweetas ut vad som finns och vad vi vet. Massor av folk retweetar. Saker sprids väldigt väldigt snabbt och mycket och vi som är aktiva i kanalen inser snabbt att vi sitter i centrumet av informationen med möjligheten att tweeta ut aktuell information till flera tusen läsare(detta utan bra källa), så vi jobbar på…

Mitt i härvan togs deras hosting på Amazon ner, helt utan förvarning. Så man bytte primär host för siten tre gånger på ett par timmar under förmiddagen. Telecomix topic hade alltid senaste infon och var inte långsamma på att trycka ut nyheter i sitt twitterflöde.

Vi satte upp en mirror på en server jag delar på med ett par vänner. Den blev snabbt populär, det var troligtvis en av de 10 första speglarna som skapades av Wikileaks specifikt för detta syfte. Vi spred denna länk via Telecomix twitterflöde, och ja, den spreds snabbt och mycket. Det första var bara en snapshot av wikileaks egna server som vi tog en mirror av, men senare på kvällen utvecklade vi vår mirror lite. Vår mirror fick namnet: <http://cablegate.failar.nu/>

Vid denna tidpunkt så var det dags för mig att ta mig mot stan, en ganska opassande dag att göra annat än att bevaka flödena och försöka hålla ordning. Tack vare min N900 så hade jag ganska bra koll på vad som hände och kunde göra administrativa saker även när jag åkte. Sveriges Radio i P3 Nyheterna rapporterade först att EveryDNS hade tagit ner WikiLeaks på grund av alla attacker som var, detta var såklart en lögn. Jag twittrade detta till de genom Telecomixflödet, rätt ska vara rätt. Nästa nyhetssändning hade de tagit in en “datorexpert” som förklarade vad som faktiskt hände och vad det innebar. Hemsidan var tillgänglig och hade alltid vart det, gällde bara att veta var man skulle leta.

Schweiziska Piratpartiet gjorde sedan en fin insats och köpte *wikileaks.ch* och pekade den på wikileaks server, den fungerade bra och blev det nya “primära domännamnet” som användes av folk flitigt. Fick sin största genomslagskraft någonsin efter att vi kört det genom Telecomixflödet. Problemet med *wikileaks.ch* var dock att den hostades hos EveryDNS, precis som *wikileaks.org* också gjorde innan EveryDNS tog bort deras records för att ta bort det ända incitamentet som fanns att DDoSa deras namnservrar… Senare på dagen så var EveryDNS’s namnservrar nere, helt, alla fyra. Vilket är väldigt extremt för att vara en så stor host av DNS. Resultatet blev förståss att *wikileaks.ch* gick ner och man fick falla tillbaka på IP-Adress istället för att finna sin väg till deras server.

På kvällen sedan när jag kom till krogen så kom vi fram till att vi borde uppdatera vår mirror av wikileaks bättre än bara på måfå ibland. Så på krogen, med en cider i ena handen och min N900 i andra så hackade jag ihop ett script som mirroar om hela siten till en mapp, lägger filerna rätt, lägger till eventuella nya filer i repot och comittar detta. Sedan så repeteras detta varje halvtimma. Så jag har ett repo med förändringar som skett i cablegate från ~21:00 och frammåt, vi kan backa i revisioner och alltid ha intakt data oavsett vad som händer med datan på wikileaks servrar.

Det började skapas väldigt många mirrors, det var någon som räknade till 84 under kvällen i mirrorlisten, det är endel att hålla reda på. För att göra detta så gjorde de som jag också skulle gjort, startat en pad där man kan hjälpas åt att lista och sortera alla mirrors. De började på ietherpad, men de tillåter “bara” 16 pers i en pad åt gången, normaltsett är det mycket. I detta fall är det ingenting. Så de flyttade över till Mozillas öppna pad, och vad jag läst så fick även den en smak av DDoSen för att få ner Wikileaks. De flyttade sedan över listan till Tumblr som vad jag sett inte haft några problem ännu med attacker.

På kvällen så började det sedan avta hela alltihopa, men hela dagen har varit ett stort kaos. Och jag gillar det! Kaoset har satt sina spår med att det inte är myndigheter som styr Internet, Internet är en organism som tack vare alla hacktivister lever och frodas. Att DDoSa ner och få företag att ta bort namn ur namnservrar gör inte så att en hemsida försvinner, om det är en hemsida som har tagit rot som hacktivister vill ha kvar så kommer den spridas extra mycket. Efter att den bara funnits på 2 platser i början av dagen så finns det nu en lista över 84 servrar som har kopior av den, spridning huh? Inte så effektiv takedown i alla fall.

Det har vart en händelserik dag på vårt Internet, jag tror att jag är en av få som verkligen sett och har överblick över det mesta som hänt angående detta under hela dagen. Många välspenderade timmar är lagda på att kolla källor, samla fakta, filtrera data för att kunna sprida kunskap och information med kraftfulla verktyg till de som haft intresse.

> Kunskap är makt, och detta har bevisats många gånger om och om idag.

Jag har även filisoferat över hur släppet går till, de släpper ett par dokument åt gången. Detta är oerhört smart om man vill ha genomslagskraft. När de släppte WarDiary så fick det mest uppmärksamhet för att det var så mycket, men det var ingen som faktiskt lyckades smälta innehållet. Det var för mycket på för kort tid. Efter att ha filisoferat över det så gillar jag skarpt att de gör precis som de gör just nu. Det är bra.

Och så måste jag lämna ett stort tack till Telecomix, för att de finns. För att folket finns. För att folk arbetar i grupp så bra och hjälper till med saker. Under perioder idag när jag gjorde annat så var det andra som hade koll. Vi har haft konstant koll hela dagen. Och Telecomix twitter har vart en mycket bra kanal att föra ut information om vad som faktiskt händer, *“Telecomix News Agency – Reporting Live From the Internet”*. Och det är exakt vad som gjorts idag.
