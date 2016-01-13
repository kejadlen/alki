# Alki

## Setup

Requires Ruby 2.2.3 and Postgres.

### Environment

Alki uses the following environment variables for configuration:

- TRELLO_KEY, TRELLO_SECRET for communicating with the Trello API. These can be obtained [here](https://trello.com/app-key).
- SECRET for the cookie secret.
- DATABASE_URL to connect to the Postgres database.

### Database

```
createdb alki
rake db:migrate
```

## Pushing to Cloud Foundry

```
cf push
```

## Development

```
bundle install

createdb alki_test
DATABASE_URL=postgres://localhost/alki_test rake db:migrate
```

To run the development server:

If postgres is running: `rerun --no-notify -- rackup`

Otherwise, `foreman start -f Procfile.dev`

### Running the tests

```
rake
```

### Jasmine

Open file://<repo root>/jasmine/SpecRunner.html in a browser.