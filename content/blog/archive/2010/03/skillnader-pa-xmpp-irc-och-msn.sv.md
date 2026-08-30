---
title: 'Skillnader på XMPP, IRC och MSN'
date: '2010-03-18T12:00:00+0100'
url: /index.php/2010/03/skillnader-pa-xmpp-irc-och-msn/
draft: true
tags: [Mjukvara, Jabber, MSN]
---

XMPP är till skillnad från MSN och IRC ett väldigt modernt och ungt chatprotokoll, som har fokus på Instant Messanging, som MSN har varit kända för.

Skillnaderna mellan MSN, IRC och XMPP är många, men de liknar ändå varandra till viss del.

Hur är dessa uppbyggda då? Hur går trafiken?

**IRC är ganska simpelt.**

I ett IRC-nätverk så har man en eller flera servrar som kommunicerar med varandra.

På ett IRC-nätverk finns kanaler. I kanalerna finns den användare som diskuterar olika saker. Man har även möjlighet att skicka PMs till folk om man känner för detta.

IRC är väldigt serverorienterat, du hänger på ett nätverk i en kanal, ditt nick är bara ditt och du måste vakta det. IRC är inte bundet till någon form av konto(med vissa undantag), eller leverantör.

IRC saknar dock en hel del funktionalitet som man kan vilja ha i moderna nätverk, tex en fastslagen teckenkodning, att SSL är standard från början, att man inte är bunden till en server på ett nätverk, osv… En kontaktlista är något många gillar, offlinemeddelanden… Visst jag stänger aldrig av min IRC-Klient, men det är inte alla som alltid kör sin klient.

I IRC så skickar du ditt meddelande från din klient, till den server du är ansluten till, som skickar vidare till de servrar där alla mottagare finns, som skickar ut det till alla mottagare.

**När man kommer till MSN då.**

MSN är mest äckligt, det finns fria implementationer av detta som man lyckats skapa genom att scanna trafik. Men det är inte rätt väg att gå. Ett protokoll bör vara öppet från början. Men detta är inte en rant.

MSN är bundet till en leverantör, du måste ha ett konto hos denna för att använda tjänsten. Och du kan bara lägga till folk på samma server som du, men det finns ju bara “en” server så det är lugnt.

Om denna ända nod av MSN slås ut så dör hela nätverket, det är inte en bra struktur ur en nätverkssynpunkt. Visst de har felra serverhallar med datorer för att driva det utspridda. Men går en eller ettp ar sådana ner ett par timmar så brukar hela nätverket lida av överbelastning.

MSN är helt okrypterat som standard(enligt den senaste information jag fått). Det finns i verkligheten enbart en klient, och den fungerar inte i mitt OS.

Jag slutade använda det för 2 år sedan, mitt liv blev mindre jobbigt så. Massor av problem försvann.

MSN applicerar även censur och tar bort inlägg som de tycker innehåller olämpliga saker.

Trafiken i MSN går från din klient, till Microsofts server, till din vän på andra sidan. och medan meddelandet är där så gås det igenom av censurlistor.

**Så vad gör XMPP bättre?**

XMPP/Jabber har ett helt öppet protokoll, så du är inte beroende av leverantör av program.

XMPP har den stora fördelen att det är decentraliserat! Så du registrerar ett konto på vilken XMPP-Server du vill, och så kan du lägga till dina vänner som har konton på andra servrar och chatta med de obehindrat. Om en server går ner så går inte hela nätverket ner.

XMPP har även fin MUC(Multi User Chat), som innebär att om du har ett JID(Jabber-ID) så kan du ta del av det som sägs i en MUC. Så det spelar ingen roll vart du har ditt XMPP-Konto, du kan ändå prata med allt och alla. Och gå med i MUCs som bor på andra servrar. En MUC är bunden till en server, och det är rimligt. Hur ska man annars kunna hitta den?

XMPP har utf-8 som standardkodning på allt. XMPP har kryptering på slaget som standard. Min klient skriker på mig om jag försöker ansluta okrypterat och säger att det är dåligt!

I Jabber så går trafiken såhär när det är **kalle@anka.se** till **jhon@doe.se**

Kalle -\> anka.se -\> doe.se -\> Jhon

Så kalle skickar sin trafik till sin provider, som pratar mod providern doe.se och skickar meddelandet dit för att Jhon ska få det. Allt detta sker krypterat.

**Vid MUC så kan det se ut såhär:**

kalle@anka.se skickar ett meddelande till kanalen *bakgruppen* på servern *bakakaka.se*

Trafiken ser då ut såhär:

Kalle -\> anka.se -\> bakakaka.se -\> alla som är i kanalen genom deras providers

Så en MUC är lite som en mailinglista, du skickar mail till en server som skickar vidare till folk på listan, fast för chat. ungefär som IRC, fast du behöver inte massor av konton och du “ansluter” aldrig till gruppchatten. Du pratar aldrig med servern gruppchatten ligger på. All din trafik går krypterat genom din provider.

Så att ansluta till Jabber gör man genom att logga in på sitt jabberkonto, för att ta sig in i gruppchatter så säger man åt sin klient att prata med sin provider och kasta in dig i en gruppchat.

Hittar du ingen provider du litar på så kan du alltid sätta upp din egna jabberserver.
