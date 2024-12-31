# chat-hook-teams
## A hook for the FiveM stock "chat" resource to enable team-based message filtering
### Overview
This resource is supposed to be called from other server resources using events. It allows players to be placed in teams and filter the chat message dispatch based on players' teams. Messages are sent to a union of teams, ie. if sender only belongs to team A and player belongs to both team A and B, the player will see the message regardless. If a sender doesn't belong to a team, no filtering is done.

While not recommended, you can use the `chat-hook-teams_createChatCommands` convar and set it to `true` if you wish to use the built-in `/join teamId` and `/unjoin teamId` commands for the client. Keep in mind this will expose the resource's server event handlers.

### Event handlers
The resource provides the following server-side event handlers (by default not registered as net events):

#### `chat-hook-teams:joinTeam`
Arguments: 
- `teamId`
  - The team's ID number (can be arbitrary, so long as you keep track of it)
- `player`
  - The ID of the player to add to the team
  - Required if you're NOT using the built-in commands (where it is replaced with the player calling the command)

Adds a player to a team.

#### `chat-hook-teams:unjoinTeam`
Arguments: 
- `teamId`
  - The team's ID number (can be arbitrary, so long as you keep track of it)
- `player`
  - The ID of the player to remove from the team
  - Required if you're NOT using the built-in commands (where it is replaced with the player calling the command)

Removes a player from a team.

#### `chat-hook-teams:resetTeams`
Removes all teams. All new messages will be global again.
