# Alki

## Setup

### Have rbenv, bundler, and postgres installed.
### Set the environment variables mentioned in the Environment section below.

### Run the following commands:
```
bundle install
createdb alki
createdb alki_test
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

## Running the tests

```
rake
```

### Jasmine

Open file://<repo root>/jasmine/SpecRunner.html in a browser.

## Pushing

```
cf push
```

## Development

If postgres is running: `rerun --no-notify -- rackup`

Otherwise, `foreman start -f Procfile.dev`
