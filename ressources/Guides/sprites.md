# Sprite
Les sprites sont un concept qui peut paraître évident tant le terme est commun est répandu dans le monde du jeu vidéo, mais qui s'avère plutôt complexe et non-intuitif dans Solarus.

## Qu'est-ce qu'un sprite dans solarus ?
Un sprite est, conceptuellement, un ensemble d'animations, qui peut être affiché.  
Concrètement, cela désigne deux choses : 

Dans le contexte du jeu, un sprite est un objet indépendant, qui contient plusieurs **Animations** (chacune possédant un nom) ; chaque Animation contient une ou plusieurs **directions** (numérotées), qui correspondent chacune à une image potentiellement animée (une animation au sens basique du terme donc, à ne pas confondre avec les Animations mentionnées plus tôt). Chaque sprite possède à tout instant une *Animation actuelle* et une *direction actuelle* : quand il faut afficher le sprite, c'est la direction actuelle de l'Animation actuelle qui sera affichée.

Cependant le terme peut aussi désigner les *fichiers sprites*, qui contiennent toutes les informations nécessaire au fonctionnement d'un sprite (c'est à dire la liste des Animations, leurs directions, et toutes leurs propriétés)/

Pour faire simple (et moins confus) : une quest possède un ensemble de fichier sprites : à divers moments (quand une entité est créée, ou quand un script le demande directement) solarus va créer un sprite à partir d'un fichier sprite. 

Ce qu'il est important de comprendre est que les sprite sont *indépendants*, c'est à dire qu'ils ne dépendant pas d'un autre objet (entité, map) pour fonctionner. En fait, il est tout à fait possible de créer un sprite tout seul, lié à aucune forme d'entité.

## Images animées
Comme mentionné plus tôt, chaque direction est une image qui peut être animée (le délai entre les frames faisant partie des propriétés de la direction). Dans ce cas, l'animation (encore une fois au sens strict du terme) est gérée automatiquement par le sprite : dès qu'une animation est lancée (c'est à dire quand l'Animation actuelle ou la direction actuelle changent, et que la nouvelle direction qui doit être affichée est animée, ou simplement quand le sprite est créé), Solarus fait "tourner l'animation en fond", c'est à dire qu'il sait en permanence quelle frame il doit afficher.

## Sprites d'entités
Si j'insiste sur le caractère indépendant des sprites, c'est pour éviter l'une des confusions que je vois le plus souvent avec solarus : il n'y a jamais réellement de "sprite d'une entité", simplement un sprite qui sera généralement utilisé pour cette entité. Un sprite n'appartient pas fondamentalement à une entité, mais le fonctionnement interne de solarus et/ou nos scripts feront que certains seront au final utilisés pour afficher telle ou telle entité.  
Évidemment, même si le sprite n'a pas besoin d'une entité pour fonctionner, les entités interagissent quand même avec eux, dans le sens où une entité liée à un sprite va régulièrement changer son Animation / direction actuelle.

Pour résumer : 
- Solarus va parfois créer un sprite lié à une entité
    - N'oubliez pas que dans les [propriétés des entités](mapping.md#entités), on peut indiquer un sprite (dans ce contexte on parle évidemment d'un fichier sprite) : le cas échéant quand l'entité est créée, Solarus crée également un sprite à partir du fichier sprite indiqué dans ses propriétés, et le lui associe.
    - Sinon, les scripts peuvent toujours associer arbitrairement un sprite à une entité.
- A chaque fois qu'il faudra afficher l'entité, c'est le sprite qui indiquera quoi afficher, en fonction de sa propre Animation / direction actuelle
- En fonction de ce qui arrive à l'entité, elle modifiera parfois l'Animation / direction actuelle du sprite (exemple : quand Link ouvre une porte, c'est l'animation nommée "open" qui devient l'animation actuelle)

## Image source
Un sprite contient des Animations, qui contiennent des directions, qui représentent chacune une image (animée). Cependant il est important de comprendre que le Sprite ne contient pas réellement l'image. Il se contente de savoir quelle est l'**image source** dont il tire ses visuels, et quelles zones de cette image correspond à chaque direction (chaque Animation peut avoir sa propre image source ; il s'agit en quelque sorte du même système que les Tilesets, qui correspondent à une image source ainsi qu'à un fichier de données)

Cette image peut être un fichier image fixe (c'est ce qui se passera dans la plupart des cas), ou alors une image dépendant du tileset actuel.  
En effet [comme mentionné dans le guide Tilesets](tilesets.md#concept), chaque tileset possède obligatoirement une image source pour ses tiles (`nomdutileset.tiles.png`) et un fichier de donnée contenant la position de chaque pattern sur l'image source, mais il peut y avoir un 3ème fichier nomé `nomdutileset.entities.png`. Ce fichier est la "sprite image" de ce tileset, et les sprites ne possédant pas d'image source utiliseront la sprite image du tilset de la map actuelle comme image source.  
Étant donné que les sprites ne retiennent que la position de leurs frames sur l'image, il est important que toutes les sprite images soient organisées de la même manière (c'est à dire que par exemple si un sprite de porte utlise une sprite image de tileset, il ne fonctionnera qu'avec les tilesets pour lesquels la porte se trouve à une position spécifique de la sprite image).

## Résumé du fonctionnement des sprites
![]()