# Mapping avancé
Ce guide est une suite à celui dédié au [Mapping](mapping.md). Il couvrira les éléments que j'ai jugé trop spécifiques pour le guide mapping, afin de conserver une certaine clarté dans celui-ci.

## Entités custom

Les scripts d'entités custom disponibles (et utiles pour le mapping) sont : 

- interaction_box : Doit être liée à une autre entité "cible" avec laquelle il est possible d'interagir, comme un PNJ, en lui donnant la propriété `target : <nom de l'entité cible>`. Lorsque Link interagira avec cette entité, ce sera comme si il avait interagi avec l'entité cible.  
Utilisation typique : en placer une sur un objet du décor et la lier à un PNJ pour déclencher le dialogue de ce PNJ lorque Link interagit avec l'objet.  
Note : lier une interaction box à un switch fera qu'interagir avec l'interaction box activera le switch.
- platform : Une plateforme mouvante. Une plateforme (donc une zone solide sur laquelle Link peut marcher) en mouvement. Sa direction de déplacement doit être indiquée en lui donnant la propriété `direction : <ID de la direction>` (les ID de directions vont de 0 pour la droite à 3 pour le bas). Elle s'arrête en touchant un mur.
(il est important de spécifier un sprite, sinon il s'agira simplement d'une plateforme invisible. Elle prendra la taille du sprite)
- dungeon\_statue\_eye : A placer sur les statues à l'entrée du donjon. Affiche simplement un oeil regardant vers Link.
- unstable_ground : entité se comportant comme un sol traversable, à la différence qu'elle commence à trembler si link y reste 1.5s, et disparait 1.5s après avoir commencé à trembler, même si link n'y est plus. De même que pour la plateforme, il est nécessaire d'y associer un sprite.
- shop_item : Item achetable. Il est nécessaire d'y associer 3 propriétés custom : 
	- `item : <nom_item>` : le nom d'un item, qui sera obtenu à l'achat (voir la partie Item et sauvegarde)
	- `variant : <variante>` : la variante de l'item qui sera obtenue.
	- `price : <prix>` : le nombre de rubis que coute l'item (qui sera donc retiré au compteur de rubis à l'achat).   

	Il est existe également une quatrième propriété, `savegame_variable : <nom_de_variable>`, qui associera ce shop item à une variable de sauvegarde, ce qui aura pour effet que l'item ne pourra être acheté qu'une seule fois (la variable de sauvegarde sera donc utilisée pour conserver l'état de ce shop item s'il a déjà été acheté ; voir la partie Item et sauvegarde.)

- npc : entité au fonctionnement similaire à celui des PNJ, à quelques exceptions près.
Premièrement, solarus gère automatiquement le fonctionnement du sprite des PNJ normaux (changements d'animations, etc, tel quel mentionné plus haut), mais pas celui des entités custom de type npc.  
Cette entité conserve cependant, du comportement des sprites de PNJ, le changement du direction si Link interagit avec, *sauf* si l'entité possède la propriété `no_turn` (peu importe la valeur).  
Pour définir un dialogue qui s'affichera automatiquement quand Link interagira avec cette entité, (comme pour les PNJs normaux avec l'option "afficher un dialogue" donc), il faut lui affecter la propriété `dialog : <nom dialogue>`.

- pickable : entité au fonctionnement similaire à celui des Trésors ramassables, à quelques exceptions près.  
Premièrement, le paramétrage du trésor (item, variante et variable de sauvegarde) se fait via les proprités custom `item`, `variant` et `savegame_variable` (exactement comme por le shop item).  
Ensuite, il es possible de lui donner un effet, qui se déclenchera lorsque Link la ramassera, via la propriété `on_obtained : <event string>`. "event string" désigne l'effet en question, décrit d'une manière expliquée dans la section [Event Strings](#event-string) plus bas.  
(Pour les programmeurs : de plus, du côté du script, cette entité possède un callback `on_obtained`, contrairement aux pickables de base) 

- poisoned_water : entité à placer par dessus les tiles d'eau empoisonée (qui ne sont que purement décoratives sans cette entité), et qui inflige régulièrement des dégats à Link tant qu'il se trouve dans cette entité.

- pull_lever : Levier à tirer. Bon franchement lui il est compliqué ce serait trop long à expliquer ici.

## Map features

Les map features sont simplement les fonctionnalités que j'ai ajouté à celles de solarus concernant les maps et les entités.

La plupart du temps, il s'agit d'affecter une propriété à une entité afin de modifier son comportement. Elles sont surtout utile pour "programmer" le fonctionnement des donjons, mais aussi dans beaucoup d'autres situation.  
Il est à noter que la plupart des map features doivent être activées dans le code, via une fonction à appeler au chargement de la map. Voir la section dédiée à l'API des maps pour plus d'informations ... ou simplement avec les codeurs. Ces fonctions seront mentionnées dans ce guide, mais n'y prêtez pas attention si vous ne comptez pas toucher au code.

Les maps features disponibles actuellement sont les suivantes : 

- **Group Loot** : il est possible de faire en sorte que Link doive tuer tout un groupe d'enemi pour loot un item (le dernier enemi à mourir droppera l'item). Pour cela, ajouter la propriété `group_loot : <nom_de_l'item>#<variante>$<variable>` à tous les enemis du groupe. (le `#variante` est inutile si l'item n'a pas plusieurs variantes). La `variable` est la variable de sauvegarde dans laquelle sera conservée l'état du trésor : s'il y en a une, le trésor ne réapparaitra pas (à utiliser pour les drops uniques).
L'item spécifié ne sera drop que lorsque tous les enemis avec la propriété `group_loot` avec la même valeur auront été tués. Par la même valeur j'entends bien le **même texte** comme valeur de la propriété, pas juste le même item : un enemi avec `group_loot : rupee#1` et un autre avec `group_loot : rupee#3` ne fonctionneront pas entre eux.  
*Exemple : si trois moblins possèdent la propriété `group_loot : rupee#3$map_1_rupee`, tuer le dernier moblin droppera un rubis, de variante 3 (c'est à dire le rubis rouge), et une fois récupéré une fois ce rubis ne sera plus jamais droppé. Enlever la partie `$map_1_rupee` fera que le rubis pourra être droppé à l'infini.*  
*Cette feature s'active via la fonction `map:init_enemies_event_triggers()`*

- **[Séparateurs](mapping.md#Séparateurs)** : il existe deux map features concernant les Séparateurs : 
	- `no_save` : si un séparateur possède la propriété `no_save` avec n'importe quelle valeur, il ne sauvegardera pas la position de Link quand celui-ci le traversera (voir partie Séparateurs).
	- dungeon style scrollings :  cette Map feature ne nécessite pas de propriété, il suffit juste de l'activer la fonction `map:init_reset_separators()`. 
	Si cette feature est activée, passer un séparateur réinitialisera complètement les enemis et blocs présents sur la map (sauf, dans le cas d'un enemi, s'il est déjà mort et que son état est sauvegardé).
	Par exemple, dans la plupart des Zelda 2D, quand Link sort d'une salle et y retourne, les enemis sont de nouveau là (sauf les boss). Ici c'est la même idée, si dans un donjon on met des séparateurs entre chaque salle, le donjon ne comportera comme un donjon de Zelda 1.  
	Il existe deux propriété permettant de modifier ce fonctionnement : 
	- donner la propriété `auto_separator` à un séparateur désactivera ce fonctionnement pour ce séparateur. Si dans la ligne d'activation on ne met pas `true` entre parenthèses, ce sera la contraire : seuls les séparateurs avec cette propriété auront ce fonctionnement.
	- donner la propriété `no_reset` à un ennemi/bloc l'excluera de la réinitalisation, il ne sera jamais réinitialisé.

- **Capteurs persistents** : donner la propriété `persistent` à un capteur fera qu'il sera toujours considéré comme activé même si Link n'est plus dessus.
  
- **Blocs activables** : donner la propriété `activate_when_moved` à un bloc fera qu'il sera considéré comme activé quand Link le déplacera. Il restera alors toujours activé, sauf s'il est réinitialisé (par un séparateur par exemple, voir plus haut). *S'active via la fonction `map:init_activatables()`*          

- **[destructible](mapping.md#Destructible)** : Donner à un [destructible](mapping.md#Destructible) la proprété custom `savegame_variable : <variable>` fait que le destructible est détruit définitivement : l'état (détruit ou non) du destructible sera sauvegardé dans la variable nommée. (plus précisément, détruire le destructible cahngera la valeur de cette variable, et il ne sera spawn au chargement de sa map que si la variable en question n'existe pas encore).

- **Entités liées au scénario** : dans Fallen Realm, l'avancement de la quête est représenté par une valeur numérique appelée story state (qui est techniquement, une simple variable de sauvegarde. Vous trouverez une liste des significations des différents story states dans les messages pin du channel #code du discord.)  
	- La propriété `min_story_state : n` fera qu'une entité n'apparaît que si le story state est de n au moins.  
	- La propriété `max_story_state : n` fera qu'une entité n'apparaît que si le story state est de n au plus.  
	- La propriété `is_story_state : n` fer qu'une entité n'apparaît que si le storsy state est de n exactement.  
	- La propriété `spawn_savegame_variable : <variable>` indiquera au jeu de sauvegarder, dans la variable de sauvegarde indiquée, si l'entité a été activée ou désactivée (par un trigger, ou directement un script). C'est à dire que (cas le plus courant) s'il s'agit d'une entité non-active au démarrage, et qu'un trigger la fait apparaître, le jeu le retiendra et les prochaines fois que la map sera chargée cette entité sera directement activée.  
    	```
    	Exemple:
    	un coffre possède la propriété "spawn_savegame_variable:dungeon_test_chest". Il n'est pas actif au démarrage, et un bouton possède un actiavate_trigger faisant apparaître ce coffre. Une fois que ce bouton aura été activé, faisant apparaître le coffre, la variable de sauvegarde "dungeon_test_chest" contiendra "true", et les prochaines fois que cette map sera chargée le coffre sera actif dès le début.
    	```


- **Triggers** : le coeur de la gestion du fonctionnement des donjons.  
Un trigger est un couple `propriété : valeur` qui va permettre de déclencher une action particulière quand l'entité respecte certaines conditions (généralement, quand un certain évènement concernant l'entité sera survenu). Le nom de la propriété doit être le type de conditions, la valeur l'action à réaliser, sous la forme d'une Event String (voir la [section corespondante](#Event-String) plus bas)
Les conditions supportées pour l'instant sont : 

	- `death_trigger` : est activé quand l'entité meurt (pour un enemi). *S'active via la fonction `map:init_enemies_event_triggers()`*
	- `activate_trigger` : a placer sur un capteur ou un bouton (ou un bloc, voir plus bas), s'activera quand l'entité sera activée (quand link passe sur le capteur, active le bouton, ou déplace le bloc (voir plus bas pour les blocs). *S'active via la fonction `map:init_activate_triggers()`*

	A noter que si plusieurs entités possèdent le même trigger (c'est à dire un même type de conditions _avec la même action_), l'action ne sera déclenchée que quand les conditions seront vérifiées pour toutes les entités : si plusieurs enemis possèdent une propriété `death_trigger` avec la même valeur (donc le même effet), cette action ne sera réalisée que quand tous les enemis en question auront été tués.  
	De même, si plusieurs boutons possèdent le même `activate_trigger`, l'action ne sera réalisée que si tous les boutons sont activés *en même temps* (donc si l'un d'entre eux n'est plus activé, ça ne fonctionnera pas).

### Event String
Une event string est une manière de décrire une action qui doit avoir lieu sur la map. C'est par exemple de cette manière que l'on décrit les effets d'un trigger (rappel : l'effet, sous la forme d'event string, doit être la *valeur* de la propriété), mais aussi dans d'autres contextes : de manière générale, à chaque fois qu'une propriété d'une entité doit décrire une action (*exemple : la propriété on_obtained des entités custom de type pickable*).  
Ces events strings sont de la forme suivante : `<type d'event>:<cible>`.  
`<type d'event>` est l'action qui doit avoir lieu. `<cible>` est l'élément de la map qui doit être affecté.  (dans certain contextes il n'y a pas besoin de `<cible>`, auquel cas les `:` peuvent être omis.)

Les types d'events disponibles sont : 
- `spawn:<nom_entite>` fait apparaître l'entité dont le nom est `<nom_entite>`. L'entité doit être déjà présente sur la map mais désactivée (pour cela, quand vous la placez sur la map, décochez la case "actif au démarrage" : quand une entité est désactivée c'est comme si elle n'existait pas).
- `disable:<nom_entite>` ou `despawn:<nom_entite>` fait disparaître l'entité. Il est possible de la faire réapparaître avec `spawn`.
  (L'entité est en réalité désactivée ; quand une entité est désactivée c'est comme si elle n'existait pas)
- `open:<nom_porte>` ouvre une porte, dont le nom est `<nom_porte>` ou commence par `<nom_porte>`. Exemple : `open:door_1` ouvre toutes les portes dont le nom commence par "door_1".
- `close_door:<nom_porte>` ferme la (ou les) porte(s).
- `music:<nom_musique>` joue une musique nomée `<musique>` ; si aucune musique n'est spécifiée, où qu'il s'agit de "none", coupe simplement la musique.
- `setrespawn:<nom_destination>` change le point de réapparition, qui devient la destination nommée `<nom_destination>`.
- `teleport:<nom_map>#<nom_destination>` téléporte le héros sur la map nommée `<nom_map>` à la destination nommée `<nom_destination>`.  
  Il est possible d'omettre le nom de la map (`teleport:<nom_destination>` ou `teleport:#<nom_destination>`), auquel cas la téléportation se fait sur la map actuelle.  
  . Il est possible d'ajouter, après le nom de la destination, un `$` suivi du style de téléportation (ce qui donne donc `teleport:<nom_destination>$<style>`) ; le style peut être
  - "fade" : par défaut
  - "immediate" : téléportation immédiate, sans animation de transition
  - "light" : **pseudo-téléportation** ; par défaut, même lors d'une téléportation sur la même map la map est rechargée ; avec une pseudo téléportation le jeu change juste la position du héros. N'a de sens que pour une téléportation sur la même map, donc si on nom de map a été donné il est ignoré.  
  - "scrolling" : ne pas utiliser pour l'instant .
- `flash:<vitesse_inversée>` (sans cible) fait apparaître un flash blanc à l'écran. `<vitesse_inversée>` doit être un nombre, plus il est bas, plus l'animation de flash est rapide.  
- `call:<nom_fonction>,<argument>,...` ou `function:<nom_fonction>,<argument>,...` pour les programmeurs : appelle une méthode de la map, nommée `<nom_fonction>`. Les arguments sont optionnels.


Quelques exemples : 
- si 3 enemis possèdent la propriété `death_trigger : spawn:key_1`, et qu'il existe sur la map une clé (c'est à dire un trésor ramassable de l'item clé, désactivé par défaut) nommée "key_1", elle apparaîtra quand les 3 enemis auront été tués.
- si un interrupteur s'activant avec un bloc et 3 capteurs persistants (voir map features liées aux capteurs) possèdent la propriété `activate_trigger : door_1`, et qu'il existe deux portes nommés "door\_1-1" et "door\_1-2",  si Link passe sur les 3 capteurs et qu'un bloc se trouve actuellement sur l'interrupteur, les portes s'ouvriront.


C'est à peu près tout, normalement ce guide devrait vous permettre d'utiliser toutes les features disponibles pour le mapping, qu'il s'agisse des fonctionnalités de base de solarus, ou de mécaniques que j'ai implémenté spécialement pour Fallen Realm.  
Cependant, même toutes ces features ne permettent pas de faire n'importe quoi, et certaines maps complexes (avec des cinématiques notament) nécessiteront une programmation plus avancée, via la script de la map.

[Retour au sommaire](starting.md)