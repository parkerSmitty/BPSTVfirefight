extends CharacterBody3D

#the NPC will decide between defending an area, attacking an area, retreating, or entering a vehicle
#if it sees a player with its vision cone, it will 
#1: fight (crouching, straifing, or standing still)  (chance to throw gernade)
#2: chance to run away or charge (if low heath)
# after the player is dead, or ai has safely escaped, it will return to the begining of its decision
#life cycle and continue on from there 

enum State {ATTACK, DEFEND, RETREAT, VEHIC}
