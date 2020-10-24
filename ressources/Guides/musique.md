# Guide pour créer une musique et la transformer en type 8bit (NES/GBC)

Dans ce petit tutoriel nous allons voir comment créer une musique à partir de rien.

# 1. Télécharger les 4 indispensables

Tout d'abord, commencez par télécharger ces 3 softs qui seront nécéssaires pour mener à bien notre mission.

**Java 64bits** : [Java 8 x64](https://alonsobertrand.fr/pub/java/jre-8u271-windows-x64.exe)

==> Ai-je besoin de présenter Java ? ;)

**Tuxguitar** : [TuxGuitar 1.5.4](https://alonsobertrand.fr/pub/tuxguitar-1.5.4-windows-x86-installer.exe)

==> TuxGuitar servira à composer la partition et d'exporter le rendu final au format MIDI


**GXSCC** : [GXS CC v236](https://alonsobertrand.fr/pub/gxscc.zip)

==> GSX CC va charger le fichier MIDI et le jouer en 8bit. IL permettra d'exporter ce rendu au format WAV

**Audacity** : [Audacity 2.4.2](https://alonsobertrand.fr/pub/audacity-win-2.4.2.exe)

==> Audacity va nous permettre de faire WAV==>OGG, format utilisé par solarus

# 2. Installation de Java

Installez le sinon Tuxguitar ne marchera pas :/

# 3. Installation et configuration de TuxGuitar

Il n'y a aucun pre-requis particulier pour installer TuxGuitar.

Si vous rencontrez ce message d'erreur : 

![erreur tuxguitar installation](https://alonsobertrand.fr/ZeldaFallen/tux1.png)

Faites abandonner et lancez l'installation en mode administrateur (clic droit sur le fichier.exe -> exécuter en tant qu'administrateur)
Ceci devrait résoudre le problème.

Une fois installé, lancez Tuxguitar et allez dans Outil -> Configuration -> Son et selectionnez ces séquenceurs et Validez : 
![sequenceur midi](https://alonsobertrand.fr/ZeldaFallen/tux2.png)

Sur l'écran de base de Tuxguitar, vous avez une piste créée automatiquement, avec une vue partition sur 1 ligne, la liste des pistes en bas et les differentes options purement 'musicales' sur le bloc de gauche(type de note, armure, tempo, etc etc).
Pour créer une note, placez vous sur la partition (et sur la ligne souhaitée) et utilisez le pavé numerique pour écrire un nombre.

Par defaut, la configuration de la partition est pour Guitare 6 cordes E-A-D-G-B-E en 4/4 (binaire), en Clé de sol, à la vitesse de 120bpm ; c'est à dire DO MAJEUR

![premieres notes](https://alonsobertrand.fr/ZeldaFallen/tux3.png)

Le nombre 0 sur chaque ligne (corde) correspond a la corde joué à vide.
Sur la capture ci-dessus, j'ai donc composé avec mes 0 la suite de notes suivante : 

*Mi La Re Sol Si Mi*

Pour changer d'instrument, ou d'accordage (exemple : nous allons passer sur une guitare basse 5 cordes)
Doublez cliquer sur l'instrument (Stell String Guitar 1) a cet endroit : 

![instru](https://alonsobertrand.fr/ZeldaFallen/tux4.png)

Sur le petit menu qui va s'ouvrir, cliquez sur l'icone clé pour modifier l'accordage. Une autre pop-up va s'ouvrir et vous pourrez choisir plusieurs accordages

Selectionnez les 5cordes  B-E-A-D-G. Laissez le capodastre à 0 et faites Valider.

(B1-E2-A2-D3-G3 correspond a la hauteur 'octave'). 
 ==> Si vous mettez B2 ou B3 le SDi sera 1 ou 2 octaves plus haut. Laissez par defaut ces valeurs. svp :D

![instru 5](https://alonsobertrand.fr/ZeldaFallen/tux5.png)

Maintenant que vous avez réglé votre instrument sur 5 cordes, il va falloir passer sur un son de guitare basse

Toujours sur la pop up principale, cliquez sur l'icone clé pour modifier l'instrument.
Le 1er instru dans la liste est le DrumKit, ignorez le et passez sur *Steel String Guitar 1*.
Profitez en pour le renommer "Basse" et choisissez l'instrument *Fingered Bass* pour avoir un vrai son de guitare basse joué avec les doigts !
Faites Valider, puis fermer.

![instru 6](https://alonsobertrand.fr/ZeldaFallen/tux6.png)

Vous voilà donc revenu dans la fenetre principale de partition. Celle-ci a été modifiée il n'y a plus 6 lignes mais 5. Votre son est bien celui d'une basse et vous êtes dans les graves.

Sachez que Tuxguitar peut gérer 10 pistes/instruments de manière simultanée.

Au dela de 10, les prochaines pistes calqueront l'instrument (et seulement l'instrument) suivant un schéma précis : 
Par exemple, la piste 11 utilisera l'instrument de la piste 1, et ainsi de suite. Je ne sais pas si c'est un bug ou une limitation vis à vis du MIDI. N'abusez donc pas des instruments :')

Voilà le tour très rapide de TuxGuitar, je détaillerai plus en détail d'autres fonctionnalitées pour aller plus loin, plus tard ;D

**Sauvegarder et exporter mon travail**

- Pour sauvegarder votre travail au format tuxguitar, faites simplement Fichier --> Enregistrez sous.. et enregistrez votre fichier au format par defaut <file.tg>

- Pour exporter votre rendu au format MIDI, faites fichier --> exporter -> Exporter midi (laissez transpose à 0) puis enregistrez votre fichier au format <file.mid>


# 4. Utilisation de GSX CC
Ce petit utilitaire tout mignon tout léger et ne nécessitant aucune installation va nous servir à 2 choses : 
- lire votre fichier midi comme si vous etiez sur une NES (ou gamleboy)
- exporter le rendu au format brut WAV

Faites une extraction de l'archive Zip et aller dans le dossier crééer suite à l'extraction.
Voici le contenu du dossier
Démarrez simplement gsxcc.exe
![gsx 1](https://alonsobertrand.fr/ZeldaFallen/gsx1.png)

Pour lire votre fichier Midi dans ce logiciel.. Faites simplement un Drag & Drop (glisser > déposer) du fichier midi dans la fenetre.
Le programme va alors lire automatiquement le fichier au format 8bit <3

Si le rendu 8bit vous satisfait pleinement, alors Cliquez sur l'icone sous *Authoring*. Confirmez avec OK
Une fois qu'il a fini, le fichier WAV est créé dans le repertoire d'où provient votre Fichier MIDI.

![gsx 2](https://alonsobertrand.fr/ZeldaFallen/gsx2.png)

YAY ! tout fonctionne à merveille :3

![gsx 3](https://alonsobertrand.fr/ZeldaFallen/gsx3.png)


# 5. Installation & Utilisation d'Audacity

Dernière étape : obtenir le format OGG

**Installation** : Installez bêtement.. suivant suivant suivant OK

**Utilisation** : 
- Ouvrez Audacity, et faites Fichier -> Importer -> Audio  et charger votre fichier WAV
Le spectre dit analogique va s'afficher sur tout votre écran. 
Faites Ctrl + A et faites 'Effets' -> 'Amplification' et laissez les valeurs proposées et faites Valider

![auda 1](https://alonsobertrand.fr/ZeldaFallen/auda1.png)

Ceci va permettre d'avoir un même volume sonore entre nos fichiers sonores. Très important pour avoir qqch d'homogène !

Maintenant, exportons notre fichier au format OGG

Faites Fichier -> Exporter -> Exporter en OGG

![auda 2](https://alonsobertrand.fr/ZeldaFallen/auda2.png)

Mettez la qualité à 5 (pour du 8bit pas besoin de consommer plus de bande passante). et faites enregsitrer.

Audacity va vous proposer de rentrer des Tags ID3 tels que Auteur, Album, Année, Titre.. Vous pouvez tout laisser vide et faire simplement Valider.

Et voilà votre fichier OGG prêt a être utilisé, entendu INGAME ! <3
