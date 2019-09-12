#Guide de création des maps
Les maps sont les environements où Link évoluera dans le jeu. Elles sont donc fondamentales à son fonctionnement.

Les maps sont composées d'un décor "inerte" (donc à peu de chose près, une image de fond et des éléments de terrain), les tiles ; et d'entités dynamiques généralement contrôlées par un script (dont Link !).  
Dans ce guide je présenterai la méthodes à suivre pour créer et éditer des maps, placer les tiles, et les entités, etc.

Avant de commencer, ouvrez solarus (sans blague) et ouvrez une map en double-cliquant dessus dans l'arborescence à gauche ; ou créez en une avec clic droit sur le dossier qui la contiendra (les maps sont toujours organisées en dossiers) -> Nouvelle map.

![Image indisponible](img/mapeditor1.PNG)

A droite, l'aperçu de la map ; dans la partie centale haute vous pouvez modifier certains propriétés de votre map, telles que sa taille ou la musique qui se jouera dessus.

Comme expliqué précédemment, la map est composée d'un décor et d'éléments dynamiques posés dessus.

##Les tiles

Le décor d'une map est composé d'une multitude d'images carrées, de taille 8x8 ou parfois plus, souvent répétés.  


**Exemple** : sur cette image, on peut voir deux tiles différentes, de 16x16 pixels  
![Image indisponible](img/tiles1.PNG)  
Celle de droite n'est présente qu'une fois, mais celle de droite à été répétée pour créer le motif du sol.

####Tilesets
Ces images sont regroupées sur des **tilesets**, de grandes images contenant toutes les tiles nécessaires à une map (on trouvera par exemple un tileset pour les maisons de base, un pour le donjon 1, etc). Avant de commencer à palcer des tiles sur une map et donc construire sond écor, il faut donc choisir le tileset, dans les propriétés de la map (au centre de l'écran).

(note : vous pouvez aussi aller voir le tileset directement, avec chaque tile et leurs propriétés dont on parlera plus tard, dans le dossier `data/tilesets/`, ou en cliquant sur l'icône crayon à côté du tileset sélectionné)

####Placer des tiles

Une fois le tileset choisi, il apparaît en dessous de propriétés, juste à droite de l'aperçu de la map.  
A partir de là, c'est très simple : on clique sur une tile pour la sélectionner, pour on clique sur la map là où on veut la placer.  
Il existe quelques subtilités que j'ajouterait plus tard (mais n'hésitez pas à demander à Zuna en attendant), mais en voici quelques unes assez indispensables :

- Maintenir clic gauche appuyé quand on place une tile sur la map et déplacer la souris dans une direction répète la tile, utile pour les grandes surfaces constituées d'une seule tile répétée. Certaines tiles ne peuvent pas être répétées ; d'autres ne peuvent l'être que dans une seule direction (ex : les murs horizontaux ne peuvent être répétés qu'à l'horizontale, etc)
- Double-clic sur une tile pour afficher ses propriétés : il y est par exemple possible de chanegr manuellement leur position et leur taille.

Il est important de noter que certains tiles sont animées (toutes les frames de l'animation sont présentes côte à côte sur le tileset).

Note : certaines tiles doivent parfois se chevaucher : pour décider de laquelle s'affiche au dessus, clic-droit -> mettre à l'arrière-plan / mettre au premier plan. (voir aussi le paragraphe "couches")


####Type de terrain

De plus, il s'avère qu'en réalité j'ai menti : les tiles ne sont pas uniquement un décor inerte ; certaines peuvent interagir avec les entités. En effet, les tiles possèdent un *type de terrain* (on ne peut d'ailleurs pas savoir le type de terrain d'une tile dans l'éditeur de map : pour savoir le type de terrain d'une tile, allez voir directement le tileset).  
Ces types sont :  

- Traversable : aucun effet.
- Mur : Est considéré comme un obstacle pour les entités.
- Muret : Par défaut, exactement pareil, cependant j'ai codé certaines entités de manière à passer au dessus, comme les flèches ou les entités volantes.  
- Vide : comme traversable, avec une différence que l'on verra au prochain paragraphe.

Les autres ont des effets plus particuliers, et sont assez explicites :

- Trous, piquants, eau profonde, lave : tiles qui auront chacune particulier sur les entités passant dessus, en particulier sur Link (tue les monstres directement, et inflige des dégâts à Link avant de le faire revenir en arrière).
- Eau peu profonde, herbe : Modifie un peu l'animation de Link et joue un son lorsqu'il marche dessus. 
- Et qques autres un peu osef

####Couches
En effet, les maps se sont pas des environements *entièrement* 2D : les tiles peuvent être à différentes hauteurs, symbolisées par des couches/layers. Toutes les tiles sont par défaut à la couche 0, mais on peut changer ça avec un simple clic-droit.  
Le système est assez simple, les tiles de la couche 1 s'affiche toujours au dessus de la couche 0 (modifier l'ordre des tiles avec clic-droit -> mettre à l'arrière-plan / mettre au premier plan n'a d'effet qu'au sein d'une même couche : mettre à l'arriere plan une tile de la couche 1 l'affichera sous les tiles de la couche 1 mais au dessus de toutes les tiles de la couche 0)  
Nous y reviendront dans la partie dédiée, mais les entités se trouvent toujours sur une couche : si Link de trouve sur une couche, il y restera tant qu'il y a une tile Traversable sous ses pieds à la même couche que lui ; s'il se retrouve sur un tile avec Vide comme type de terrain, ou juste un endroit sans tile, il "tombera" (descendra les couches jusqu'à retomber sur une tile non vide ou à la couche 0.  

(note: les entités sont toujours affichées au dessus des tiles de leur couche ; pour qu'une tile s'affiche par dessus Link, il faudra la placer sur une couche supérieure à celle où se trouvera Link)

##Entités
Mon tournoi va pas tarder à commencer faut que j'y aille, bref je fais la partie sur les entités le plus prochainement possible LA BISE
