# my-hugo-blog

My blog site builder using [Hugo](https://gohugo.io)

## Need to get submodule if there isn't

```
git submodule update --init --recursive
```

## Update the contents then check them by running Hugo server in Docker container

```
docker compose up
```

## Deployment

### Preparation

You have to update `DEPLOY_TOKEN` as personal token to deploy since the token is expired within one year.

### Do deployment

```
git commit # Finish writing a blog post
```

```
./master-push-in-local.sh
```

builds and deploys the artifact onto [https://github.com/momotaro98/momotaro98.github.io](https://github.com/momotaro98/momotaro98.github.io) in GitHub Action workflow.

The GitHub Action runs `deploy.sh`.

## How to modify themes as a submodule

Update and push to the master of [this forked repository](https://github.com/momotaro98/hugo-ink).

After that, update the commit of the theme repository.

```
$ cd my-hugo-blog
$ cd themes/ink
$ git pull origin master
$ cd ../..
$ git add .
$ git commit
```
