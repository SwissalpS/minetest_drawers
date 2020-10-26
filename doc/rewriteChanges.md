rewrite changes that will need more attention
==============================================
These are changes that affect metadata fields and item definition fields
and could pose incompatibility problems

upgrades
----------
in craft item definition groups field the group
drawer_upgrade -> drawers_increment
not a problem unless another mod depends on this

trim aka connectors
---------------------
in node definition groups field the group
drawer_connector -> drawers_connector
this should not cause trouble unless another mod depends on this

cabinet
--------
in node definition groups field the group
drawer -> drawers
not a problem unless another mod depends on this

drawer_stack_max_factor
and the meta field:
drawer_stack_max_factor -> drawers_max_stacks
have been removed


controller
-----------
changed digiline channel meta field
digilineChannel -> channel
changed meta field for net_index
? -> net_index

