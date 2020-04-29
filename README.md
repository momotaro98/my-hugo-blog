# my-hugo-blog

My resume site builder using [Hugo](https://gohugo.io)

## Update the contents then check them by running Hugo server in Docker container

```
$ docker-compose up
```

## Deployment

`git push origin master` builds and deploys the artifact onto [https://github.com/momotaro98/momotaro98.github.io](https://github.com/momotaro98/momotaro98.github.io) in GitHub Action workflow.

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
