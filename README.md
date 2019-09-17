# Sensu Go Hello World Asset

- [Starting out](#starting-out)
- [Packaging the asset](#packaging-the-asset)
- [Generating the definitions](#generating-the-definitions)

This asset is the "Hello World" of Sensu Go assets. It's designed to give you an idea of how assets are packaged up and used with Sensu Go. 

If you haven't already, you should read the [Sensu Go Asset Reference documentation][asset-ref]. This will go over all the material you'll need to know to understand assets from a theoretical perspective. 

Assuming you've read that document, we can now start discussing this project.

## Starting out

So you've got a bash script that you need to run. In our case, we REALLY need to run a script that outputs "Hello World." It looks like this:

```bash
#!/bin/sh

STRING="Hello World"

echo $STRING

if [ $? -eq 0 ]; then
    exit 0
else
    exit 2
fi
```

Sure, it's basic. But it does what we need it to do. So how do we make it a reusable asset for Sensu Go? First we need to put it in the right spot. 

According to the reference document, there are three potential directories where our script could live in our project: `/bin`, `/lib`, or `/include`. For this case, we'll just use `/bin` and put our script there:

```
.
├── README.md
└── bin
    └── hello-world.sh
```

Let's make sure that it's marked as executable:

```
$ chmod +x hello-world.sh 
mode of 'hello-world.sh' changed from 0644 (rw-r--r--) to 0755 (rwxr-xr-x)
```

Ok, this is a great start. We've got our script in the `/bin` dir, it's executable...what next?

## Packaging the asset

Assets are tarballs, pure and simple. So how can we tar up our asset? First, let's tar up our directory. This assumes you're in the directory you want to tar up:

```bash
$ cd ..
$ tar -C sensu-go-hello-world -cvzf sensu-go-hello-world-0.0.1.tar.gz .
...
```

Excellent. We've got an archive. 

Now, let's generate a SHA512 sum for it (this is required, else the asset won't work)

```bash
sha512sum sensu-go-hello-world-0.0.1.tar.gz | tee sha512sum.txt
dbfd4a714c0c51c57f77daeb62f4a21141665ae71440951399be2d899bf44b3634dad2e6f2516fff1ef4b154c198b9c7cdfe1e8867788c820db7bb5bcad83827 sensu-go-hello-world-0.0.1.tar.gz
```

Awesome. Now we have our sha512sum. The last part of this portion of our exercise is getting the archive and the sha512sum somewhere where it can be hosted. You can do this with S3, a Github release, or even just serving the files out of a directory using Nginx/Apache.

In this case, we're going to use Github to serve our release. So let's go ahead and create a release. 

![Create a new github release][gh-release-01]

Once you've clicked on "Create a new release," you should see a screen that looks like this:

![Release details screen][gh-release-02]

So you can see that there will need to be some details filled out. We'll also need to drag and drop our asset and checksum to the screen so they will be uploaded as part of the release. If you've done all of that, you should see something like this:

![Release details filled in][gh-release-03]

Once you've done that, you can hit "Publish release" and you should have a release listed that looks like so:

![Completed release][gh-release-04]

Alright. Now, time to create some definitions!

## Generating the definitions

So far, we've created a directory for our asset with our script present in `/bin`, we've packaged up the asset and generated a checksum for it, we've got it hosted at Github, now it's time to generate some definitions for it to see it work. So let's start with our asset definition:

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-go-hello-world
  namespace: default
spec:
  url: https://github.com/yourusername/sensu-go-hello-world/releases/download/0.0.1/sensu-go-hello-world-0.0.1.tar.gz
  sha512: dbfd4a714c0c51c57f77daeb62f4a21141665ae71440951399be2d899bf44b3634dad2e6f2516fff1ef4b154c198b9c7cdfe1e8867788c820db7bb5bcad83827
```

Now, let's create a basic check that uses the asset:

```yaml
type: CheckConfig
api_version: core/v2
metadata:
  name: sensu-go-hello-world
  namespace: default
spec:
  command: hello-world.sh
  runtime_assets:
  - sensu-go-hello-world-asset
  interval: 10
  publish: true
  handlers:
    - debug
  subscriptions:
  - linux
```

We'll apply both of those definitions to our Sensu Go deployment:

```
sensuctl create -f sensu-go-hello-world-asset.yml
sensuctl create -f sensu-go-hello-world-check.yml
```

Now, let's take a look in the dashboard to see our check using our asset. In my case, I have an entity named `sensu-agent-01`, and I can see that the check successfully executes:

![Sensu go agent successfully executes check with hello world asset][sensu-agent-01]

There you have it! You've successfully created an asset from a script, uploaded that to Github as a release, and have created your own definitions that make use of that asset. Congratulations! 🎉🎉🎉🎉

<!--LINKS-->
[asset-ref]: https://docs.sensu.io/sensu-go/latest/reference/assets/
[gh-release-01]: http://share.sachshaus.net/4efc554512f9/%255Bee92b1343de6399b8191fee8b8dd2c57%255D_Image%2525202019-09-17%252520at%25252010.32.02%252520AM.png
[gh-release-02]: http://share.sachshaus.net/3485c10bccb0/[9b5ee5dc49432dc104bf8c6830bcf2b7]_Image%202019-09-17%20at%2010.32.43%20AM.png
[gh-release-03]: http://share.sachshaus.net/2e3e5d97454d/Image%202019-09-17%20at%2011.54.28%20AM.png
[gh-release-04]: http://share.sachshaus.net/221bef49236a/Image%202019-09-17%20at%2011.57.55%20AM.png
[sensu-agent-01]: http://share.sachshaus.net/24ef2c7ea8e5/Image%202019-09-17%20at%2012.04.35%20PM.png
