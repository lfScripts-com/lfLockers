# lfLockers

A free interactive locker system for ESX servers.

## Features

- Multi-language support (French/English)
- Personal lockers for each player
- Admin access to view other employees' lockers
- Configurable locker locations for different jobs
- Grade-based access control
- Direct locker access for non-admin players
- Support for offline players' lockers
- Real-time online/offline status display

## Dependencies

- ESX Legacy
- ox_inventory
- oxmysql

## Installation

1. Put script in your resources directory
2. Add `ensure lfCasiers` in your server.cfg
3. Configure locker positions in `config.lua`

## Configuration

### Language
```lua
Config.Language = 'en'  -- For English
Config.Language = 'fr'  -- For French
```

### Locker Setup
```lua
{
    id = "your_locker_id",
    name = "Your Locker Name",
    position = vector3(x, y, z),
    jobRequired = 'your_job',
    adminGrade = 2,
    lockerWeight = 30000
}
```

## Usage

- **Players**: Press E near locker to access personal locker
- **Admins**: Access full UI to manage employee lockers
