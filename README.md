# Alki

## Setup

```
createdb alki
rake db:migrate
```

### Environment

Alki uses the following environment variables for configuration:

```
TRELLO_KEY
TRELLO_SECRET
SECRET
DATABASE_URL
```

Trello API keys can be obtained [here](https://trello.com/app-key).

## Pushing

```
cf push
```

## Development

If postgres is running: `rerun --no-notify -- rackup`

Otherwise, `foreman start -f Procfile.dev`
