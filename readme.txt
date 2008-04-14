NLDSearchBar Readme
-------------------


NLDSearchBar is een Internet Explorer werkbalk die vanuit de browser direct 
toegang geeft tot de NLDelphi zoekmachine.


-------------------

Features:

- Zoeken! (DUH ;))
- Nieuw venster openen met Shift-Enter
- Zodra je op een NLDelphi pagina iets in de zoekmachine intikt, of beter
  gezegd, zodra je de URL van de zoekmachine opvraagt, ongeacht op welke manier,
  zal de NLDSearchBar automagisch de zoek-opdracht weergeven in z'n toolbar.


Ongewenste features (beter bekend als 'bugs'):

- De registratie gaat niet geheel goed: er komt ook een "NLDelphi ZoekBar" optie
  bij de Beeld -> Explorer-balk lijst. Alhoewel, is dit een bug? Op zich is het
  best handig om die balk onderin beeld te hebben. Ok, dit is dus een feature :)


Nog te doen:

- Voorlopig niks!


-------------------


Installatie:

1. De makkelijke weg:
      dubbelklik op "install.bat"
 
2. De handmatige weg:
      open een opdrachtprompt en voer uit: "regsvr32 NLDSearchBar.dll"


Sluit hierna Internet Explorer af, open 'm opnieuw, ga naar Beeld -> Werkbalken
en kies in het menu voor "NLDelphi ZoekBar". Voila!


Deinstallatie:

1. De makkelijke weg:
      dubbelklik op "uninstall.bat"
 
2. De handmatige weg:
      open een opdrachtprompt en voer uit: "regsvr32 -u NLDSearchBar.dll"


-------------------


Broncode:

NLDSearchBar is geprogrammeerd en getest onder Delphi 6 met IE6.
Om te compileren zijn de volgende componenten nodig:

- Indy (voor IdURI, http://www.nevrona.com/Indy/)



-------------------
NLDSearchBar is een copyright (c) 2003 van X2Software (http://www.x2software.net), 
vrijgegeven als open-source aan de NLDelphi Community onder de zlib/libpng 
licentie (http://www.opensource.org/licenses/zlib-license.php).