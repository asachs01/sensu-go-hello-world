[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/asachs01/sensu-go-hello-world)
[![Build Status](https://travis-ci.org/asachs01/sensu-go-hook-has-process-filter.svg?branch=master)](https://travis-ci.org/asachs01/sensu-go-hello-world)

## Sensu Go Hello World Asset

- [Overview](#overview)
- [Files](#files)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
  - [Sensu Go](#sensu-go)
    - [Asset registration](#asset-registration)
    - [Asset definition](#asset-definition)
    - [Walkthrough](#walkthrough)
- [Sensu Core](#sensu-core)
- [Installation from source](#installation-from-source)
- [Additional notes](#additional-notes)
- [Contributing](#contributing)

## Overview

This asset is the "Hello World" of Sensu Go assets. It's designed to give you an idea of how assets are packaged up and used with Sensu Go. 

If you haven't already, read the [Sensu Go asset reference documentation][1], which describes everything you need to know to understand assets from a theoretical perspective.

## Files

N/A

## Usage examples

N/A

## Configuration
### Sensu Go
#### Asset registration

Assets are the best way to make use of this plugin. If you're not using an asset, please consider doing so! If you're using sensuctl 5.13 or later, you can use the following command to add the asset: 

`sensuctl asset add asachs01/sensu-go-hello-world`

If you're using an earlier version of sensuctl, you can download the asset definition from [this project's Bonsai asset index page][2].

#### Asset definition

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-go-hello-world
spec:
  url: https://assets.bonsai.sensu.io/71f7d5a07057b018ea7083467b1effc5f55b310c/sensu-go-hello-world-0.0.9.tar.gz
  sha512: 89f1892cddc0c29ce8254ea458072aefd33cc395946033ca58836bfb6d22aea7df67b86c4f540612ba0cd03f23eeff712b216947a8f953f99fa519202ed9e3a9
```

#### Walkthrough

Suppose you've got a bash script that you need to run. In this case, you REALLY need to run a script that outputs "Hello World." It looks like this:

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

Sure, it's basic. But it does what you need it to do. So how do you make it a reusable asset for Sensu Go?

First, you need to put it in the right spot. 

According to the reference document, there are three potential directories where your script could live in your project: `/bin`, `/lib`, or `/include`. For this example, let's use `/bin`:

```
.
├── README.md
└── bin
    └── hello-world.sh
```

Make sure that the script is marked as executable:

```
$ chmod +x hello-world.sh 
mode of 'hello-world.sh' changed from 0644 (rw-r--r--) to 0755 (rwxr-xr-x)
```

Ok, this is a great start. Your script is in the `/bin` dir, and it's executable...what next?

**Package the asset**

Assets are tarballs, pure and simple. So how can you tar up your asset? First, tar up your directory. This assumes you're in the directory you want to tar up:

```bash
$ cd ..
$ tar -C sensu-go-hello-world -cvzf sensu-go-hello-world-0.0.9.tar.gz .
...
```

Excellent. You've got an archive. 

Now, let's generate a SHA512 sum for it (this is required for the asset to work)

```bash
sha512sum sensu-go-hello-world-0.0.9.tar.gz | tee sha512sum.txt
89f1892cddc0c29ce8254ea458072aefd33cc395946033ca58836bfb6d22aea7df67b86c4f540612ba0cd03f23eeff712b216947a8f953f99fa519202ed9e3a9 sensu-go-hello-world-0.0.9.tar.gz
```

Awesome. Now you have your sha512sum. The last part of this step is getting the archive and the sha512sum somewhere where it can be hosted. You can do this with S3, a GitHub release, or just serving the files out of a directory using Nginx/Apache.

In this example, you'll use GitHub to serve your release. So let's go ahead and create a release. 

![Create a new GitHub release][4]

After you click "Create a new release," you should see a screen that looks like this:

![Release details screen][5]

You'll need to fill in these details and drag and drop your asset and checksum to the screen so they will be uploaded as part of the release. If you've done all of that, you should see something like this:

![Release details filled in][6]

Next, click "Publish release." Your release should be listed like so:

![Completed release][7]

Time to create some definitions!

**Generate the definitions**

So far, you've created a directory for your asset with your script present in `/bin`, packaged up the asset and generated a checksum for it, and hosted it on GitHub. Now it's time to generate some definitions to see it work.

Start with your asset definition:

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-go-hello-world
  namespace: default
spec:
  url: https://assets.bonsai.sensu.io/71f7d5a07057b018ea7083467b1effc5f55b310c/sensu-go-hello-world-0.0.9.tar.gz
  sha512: 89f1892cddc0c29ce8254ea458072aefd33cc395946033ca58836bfb6d22aea7df67b86c4f540612ba0cd03f23eeff712b216947a8f953f99fa519202ed9e3a9
```

Now, create a basic check that uses the asset:

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

Apply both of those definitions to your Sensu Go deployment:

```
sensuctl create -f sensu-go-hello-world-asset.yml
sensuctl create -f sensu-go-hello-world-check.yml
```

Now, let's take a look in the dashboard to see your check using your asset. As an example, we created an entity named `sensu-agent-01`, and you can see that the check successfully executes:

![Sensu Go agent successfully executes check with hello world asset][8]

There you have it! You've successfully created an asset from a script, uploaded it to GitHub as a release, and created your own definitions that make use of that asset. Congratulations! 🎉🎉🎉🎉

### Sensu Core

N/A

## Installation from source

### Sensu Go

See the instructions above for [asset registration](#asset-registration).

### Sensu Core

Install and setup plugins on [Sensu Core](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/).

## Additional notes

N/A

## Contributing

See the [Sensu Go repository CONTRIBUTING.md][3] for information about contributing to this plugin. 

[1]: https://docs.sensu.io/sensu-go/latest/reference/assets/
[2]: https://bonsai.sensu.io/assets/asachs01/sensu-go-hello-world
[3]: https://github.com/sensu/sensu-go/blob/master/CONTRIBUTING.md
[4]: http://share.sachshaus.net/4efc554512f9/%255Bee92b1343de6399b8191fee8b8dd2c57%255D_Image%2525202019-09-17%252520at%25252010.32.02%252520AM.png
[5]: http://share.sachshaus.net/3485c10bccb0/[9b5ee5dc49432dc104bf8c6830bcf2b7]_Image%202019-09-17%20at%2010.32.43%20AM.png
[6]: https://f.v1.n0.cdn.getcloudapp.com/items/3a0n0f2z3x08133y3F1v/Image%25202019-09-17%2520at%252011.54.28%2520AM.png
[7]: https://f.v1.n0.cdn.getcloudapp.com/items/2q440A3g0F0E0J3N1A3f/Image%25202019-09-17%2520at%252011.57.55%2520AM.png
[8]: https://f.v1.n0.cdn.getcloudapp.com/items/360q0m2b3g0R2J1P1W0p/Image%25202019-09-17%2520at%252012.04.35%2520PM.png
