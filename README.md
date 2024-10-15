# Andromeda Battle Framework

**Andromeda** is a versatile battle framework for Roblox, designed to make the creation of fighting systems effortless. Whether your game features melee combat, ranged weapons, or magic spells, Andromeda handles all the tricky backend stuff so you can focus on building fun, creative experiences.

## Powered by Spark Networking
Andromeda is built with my own **Spark**—a networking module designed to make remote event handling smooth and efficient. With Spark, you can fetch remote events and functions across multiple scripts without worrying about redundancy. Its **Fake Signaling** feature lets the client act before the server has fully established events, ensuring quick, seamless interaction. Spark is designed to replace the limitations of other modules like Comm, giving you more flexibility and control without the hassle of fetching namespaces.

## Features at a Glance:
- **Priority-Based Tiebreaking**: Ever had two abilities clash at the same time? Andromeda steps in with a priority system to decide which move wins. An **Ultimate** always beats a **Light** attack, keeping combat decisions exciting and strategic.

 ```lua
 return EnumList.new('AbilityPriority', {
     'Ultimate',
     'Guardbreak',
     'Heavy',
     'Light',
     'Passive',
     'None'
 })
 ```

- **Ability Status Progression:** Moves within an ability progress through various statuses like Open, Low, Standard, High, and Locked. Locked moves can't be cancelled by the player but can be interrupted by an enemy with a higher-priority move.
```lua
 return EnumList.new('AbilityStatus', {
   'Open',
   'Low',
   'Standard',
   'High',
   'Locked'
})
```

- **State Machine Design:** Abilities are broken down into smaller, manageable components (like a move-by-move breakdown). This modular structure makes decision-making easier, while the server remains fully in control for smooth gameplay.

- **Client-Server Parallelism:** When the server starts an ability, the client is instantly notified. This keeps UI updates, VFX, and post-processing effects synced seamlessly, while the server continues managing gameplay logic. If a move is cancelled server-side, it gets cleaned up on the client too—thanks to Trove, a handy garbage collector for performance optimization.

- **Factory Patterned VFX Pipeline:** Andromeda’s Factory pattern makes visual effects run smoothly by delegating rendering and physics to the client. This frees up server resources and keeps everything looking and feeling polished during battle.

- **Weapon Data Pooling:** Weapons are temporarily sheathed during spellcasting, and the original weapon is automatically re-equipped when the spell finishes. Perfect for fast-paced gameplay where a player needs to dash into battle with boosters and immediately strike with their sword.

**Andromeda** isn’t just theory—it’s *"battle"*-tested and trusted by developers in real games! After an initial sale to a game studio, we're opening it up to the community so you can harness its power in your own projects.

# Why Andromeda? 
It gives structure to combat systems and does the heavylifting, so you can focus on making great battle mechanics. Andromeda was designed to handle abilties similar to the complexity of those seen in Valorant and is able to handle absolutely anything you throw at it, no matter how wild your ideas get. Plus, it’s open-source—so you can take it, tweak it, and make it your own.
