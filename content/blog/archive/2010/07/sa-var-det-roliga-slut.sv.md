---
title: 'Så var det roliga slut…'
date: '2010-07-22T12:00:00+0200'
url: /index.php/2010/07/sa-var-det-roliga-slut/
draft: true
tags: [Mjukvara, Piratsaker, Företag, Framtiden, Licens, Öppenhet, Piratpartiet]
---

För ett bra tag sedan, så började Adobe släppa Flash till 64-bitars Linux. Det har fungerat utomordentligt på min primära arbetsstation, min stora dator helt enkelt. Jag har kunnat titta på SVTPlay, lyssna på program hos SR och så. Det har varit trevligt att ha den tillgången. Jag gillar deras utbud.

Synd bara att det inte är tillgängligt längre, för att Adobe huxflux tog bort stödet för mitt system. Jag kör ju ett egenihopklistrat gentoo, men även andra system. Tex [Debian](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=586273) har det inte helt problemfritt heller.

När jag förlorade mitt stöd för Flash så var jag i början en smula irriterad, jag kunde inte kolla Google Analytics(Det jag använde Flash mest för). Och senare har jag varit väldigt lättad. Jag har länge tänkt att jag ska ta bort skiten men inte kommit för mig. Men jag gillar inte skräpande paket, så nu blev det av. Vad ska jag med det till? Det fungerar ju ändå inte.

Senare blev jag en smula besvärad, jag kunde inte längre ta del av Public Services sändningar på Internet. Det finns en hel del saker där jag gillar att se/lyssna på. P3 det är bra grejer. Men tyvärr går det inte längre… Adobe var det ja…

Jag visste att detta skulle hända, det var bara en frågan om tid. Men jag hoppades ju lite på att den skulle finnas kvar. **Men efter att jag funderat på det så är jag lättad över att ha blivit av med Flash.**

Men jag vill fortfarande kunna komma åt Public Service på Internet, när jag sitter och surfar eller programmerar så vill jag ha något i bakgrunden, det är trevligt för det mesta :)

Ett par dagar senare fick jag reda på vad SVT har för kriterier på framtida format, så jag lade upp en pad där jag kommenterade punkterna en i taget med utgångspunkt från hur det ser ut idag. Och så länkade jag den i ett antal IRC-kanaler och frågade om hjälp med att göra den bättre, och bättre blev den. Jag måste nog klassa det klart.

Och jag tänkte publicera dokumentet här och sedan maila det till SVT, men man borde dra det till SR också. Men då kan man behöva lite annorlunda angreppspunkter.

Vi är 4 personer eller fler som tillsammans har skrivit detta under ett par dagars tid, tillsammans över internet, och det var tänkt från början att det skulle vara ett öppet brev, så jag bara klistrar in hela här.

> **Öppet brev till Teknikavdelningen hos SVT för SVTPlay:**
>
> Vi satt och tittade på följande sida angående SVTPlay: <http://svt.se/svt/jsp/Crosslink.jsp?d=104149&a=1395800>  
> Och har lite kommentarer om hur vi uppfattar era krav, och hur ni följer era krav, samt hur ni kan göra för att förbättra er tjänst i framtiden.
>
> **Detta är de krav som SVT tagit fram på sina framtida format:**
>
> - **Tillgänglighet:** Formatet ska vara en leverantörsoberoende och etablerad standard. Det ska finnas bra stöd för formatet i en rad olika, kostnadsfria mediaspelare på alla plattformar (Windows, Mac, Linux).
> - **Användarvänlighet:** Det ska inte kräva en invecklad installationsprocedur, det ska vara enkelt för de flesta användare att komma igång.
> - **Skalbarhet:** Formatet ska vara lämpligt för distribution av korta såväl som långa sändningar, live eller on-demand. Man ska kunna erbjuda rörligt material anpassat för konsumtion via olika typer av internetuppkoppling (analog, bredband, mobil).
> - **Teknisk kvalitet:** Det ska se bra ut (så bra som möjligt): i mobilen, på datorskärm och på alla framtida typer av tv-skärmar.
> - **Kostnad:** För besökaren ska det alltid finnas gratis mediaspelare som lämpar sig att spela upp formatet på alla olika plattformar. För SVT ska det inte vara särskilda kostnader inblandade i produktion och distribution av formatet jämfört med andra alternativ. Formatet ska vara licensfritt för SVT.
>
> **Dessa kraven ni lagt upp som ska följas för framtida format. Vi tänker lägga en kommentar på alla dessa. En åt gången, med utgångspunkt från hur det ser ut idag och hur det kan förbättras.**
>
> ## Tillgänglighet
>
> Flash som ni använder idag är inte tillgängligt på det sättet ni beskriver det. Det finns enbart en leverantör av Flash-spelare. Den mjukvara som levereras fungerar dåligt i både Linux och Mac, detta med anledningen att Adobe (som än ensam leverantör) inte lägger energi på andra plattformar än Windows.  
> Vi vill lägga fram ett förslag att ni går över till den nya standarden för video på hemsidor som finns i HTML5 (se Youtube <http://www.youtube.com/html5> och <http://www.html5video.org/demos/> ). Man kan man direkt per design bädda in videos i hemsidor och låter webbläsaren spela upp video och får optimerad uppspelning med videoacceleration på alla plattformar. Det aktuella formatet kommer vara WebM (med tillhörande kodnings och avkodningsverktyg för VP8 och Vorbis), WebM har sin officiella hemsida här: <http://www.webmproject.org/>
>
> *WebM kommer att kunna spelas upp i framtida versioner av webbläsarna Google Chrome, Firefox och Opera, utan insticksprogram. Efter en osäkerhet vid projektets lansering om det skulle få stöd från de två största kommersiella browser-företagen, har nu Microsoft tillkännagivit att även Internet Explorer (version 9, och antagligen även senare) kommer kunna spela formatet om WebM-kodeken har installerats på datorn. Apples Safari har utlovats kunna spela upp formatet. Adobe har tillkännagivit att även Flash Player kommer ha stöd för formatet.* — Källa <http://sv.wikipedia.org/wiki/WebM>
>
> Eftersom Flash inte är tillgängligt på Apples mobiltelefoner, musikspelare eller surfplatta har Flash verkligen blivit en begränsning av tillgängligheten för många. Här är ett öppet brev från Steve Jobs till Adobe om varför: <http://www.apple.com/hotnews/thoughts-on-flash/>
>
> Efter senaste uppdateringen av Flash så kan inte jag se på videos hos er över huvud taget. Jag kör ett 64-bitars Linux-system. Jag körde tidigare 64-bitars Flash för Linux. Men denna finns inte längre. Så länge den fanns så fungerade Flash för mig, nu finns den inte längre.
>
> ## Användarvänlighet
>
> Flash är dåligt användarvänlighetsmässigt på flera vis. Ett fält där det är speciellt dåligt är för personer som har dålig syn så att de tvingas till att använda skärmläsare ( <http://en.wikipedia.org/wiki/Screen_reader> ). Det blir för användarna av skärmläsare ungefär samma effekt som om man bygger en hemsida helt i bilder. De kan inte få fram innehållet, eftersom skärmläsaren inte vet hur den ska läsa upp någon text. Att försöka lösa detta i Flash är inte heller hållbart i längden.
>
> Jag tycker inte att det är speciellt användarvänligt mot mig som är datortekniker när de i princip tar bort stöd för arkitekturen mitt operativsystem är kompilerat för, bara för att de kan. 32-bitarssystem kan knappas ses som att gå framåt i tiden, det är snarare bakåt. Jag kan inte heller göra något åt detta, då Flash är ett ofritt otillgängligt format med bara en leverantör. De fria implementationerna (Gnash, mm) är inte tillräckliga då deras utvecklare inte har samma resurser och sällan kan hinna ikapp med nya funktioner, detta är för att Adobe inte ger ut någon dokumentation över huvud taget, bortsett från för delar av swf-filformatet.
>
> ## Skalbarhet
>
> Vilka upplösningar man sänder i påverkar ju bandbreddsanvändningen mest. Man kan göra som YouTube har gjort och ge möjligheten till olika upplösningar. Det är inget stort problem tekniskt sätt. Vill man ha högre upplösning så tar det mera bandbredd. Dock så sägs WebM vara snål när det gäller bandbredd över lag. Den enkla lösningen är att skapa flera videofiler i olika upplösningar för varje videoklipp. Med tanke på att terabytehårddiskar kan köpas för under tusenlappen numera så är lagringen inte längre ett problem. SVT behöver inte heller hantera så många videoklipp att processorlast för kodantet av videon blir ett problem, det kan faktiskt göras på en ensam hemdator i en del fall (exempelvis konstant encoding av SVT:s sändningar till WebM i “normalupplösning”).
>
> ## Teknisk kvalitet
>
> Om man kodar videon rätt från en bra källa så kommer resultatet se bra ut om man har en bra mediaspelare. Hanteringen av uppspelning är något webbläsare ska styra, vilket de flesta stora webbläsare redan gör. Kvaliteten med Flash är dock ett större problem, jag vet att ni i nuvarande spelaren har lyckats relativt bra. Nu kan jag ju dock inte spela upp något alls, så jag känner att den tekniska kvaliteten har sjunkigt till mig som användare till en väldigt obefintlig nivå. WebM, som är helt fritt, ska dessutom matcha den proprietära konkurrenten h264 (som består av flera codecar) i kvalitet-per-bit, och är dessutom anpassad för streaming (företaget som skapade den, On2, har sysslat mycket med saker som videokonferenser, vilket är tekniskt sett är videostreaming). De som är insatta vet att h264:s stöd för streaming kräver många “fula hack” då det inte var vad det skapades för. Även om h264 kan ge något bättre kvalitet-per-bit så kommer kvaliteten på användarupplevelsen vara sämre. Webbläsare som Firefox kommer under sin nuvarande licensform inte kunna implementera h264 på grund av dess licens.
>
> ## Kostnad
>
> Med tanke på att Flash inte uppfyller kraven på tillgänglighet så är det ett dåligt allternativ. Det finns inga alternativa Flash-kloner som fungerar tillräckligt bra, samt att formatet inte är så pass öppet så att man kan skapa en fri Flash-klon (komplett klon, inklusive kodekar och alla avancerade funktioner), så är Adobe de enda som kan se till att det finns spelare för de OS ni säger att ni ska stödja – de tog exempelvis nyligen bort stödet för mitt OS, jag känner en ganska stor avsaknad av att inte kunna titta på SVT-Play på min primära arbetsstation.
>
> WebM är BSD-licenserat samt DRM-fritt. Det kommer inte under några omständigheter uppkomma några kostnader för de som skapar video eller för de som tittar på video, om inte användaren väljer att köpa ett annat program för att spela upp det. Men det kommer alltid att finnas fria spelare som klarar av formatet.
>
> **Namnlista med folk som skrivit:**  
> Elis Axelsson — <http://elis.nu/>  
> Bengt Vänerhall  
> Isak Gerson — <http://isakgerson.se/>  
> Med flera…

Ska bli intressant att se vad jag får för svar… Kommer följa upp det här.
