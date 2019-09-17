# Sensu Go Hello World Asset

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

Assets are tarballs, pure and simple. So how can we tar up our asset? 

<!--LINKS-->
[asset-ref]: https://docs.sensu.io/sensu-go/latest/reference/assets/