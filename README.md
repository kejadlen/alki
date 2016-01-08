# Alki

## Setup

```
createdb alki
```

## Pushing

```
cf push
```

## Migrating

```
cf push -c 'rake db:migrate' -i 1
cf push -c 'null' -i 4
```
