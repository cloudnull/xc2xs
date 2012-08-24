Xen Classic (Open Source) to XenServer Converter
################################################

Why would you want to convert to XenServer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The simple answer is XenServer is the platform that Rackspace will be supporting for the forseable future.  This means that all development will be done on the XenServer platform.  The long answer has to do with both Memory utilizations as well as IO performance. Additionally, Rackspace has made a change to the infrastructure allowing image snapshots of up to 160GB for both Linux and Windows. These benefits are some of the reasons why you may want to convert from Xen Classic (Open Source) to XenServer.

Preface
^^^^^^^

This was my Origin Servers Image 
 * Rackspace Cloud Server
 * Image 77 - CentOS 5.6
 * Flavor 1 – 256MB

This was my Destination Servers Image 
 * Rackspace Cloud Server
 * Image 114 - CentOS 5.6
 * Flavor 1 – 256MB

Please note 
 I did test this process on Debian as well. I migrated from Debian 5 Xen Classic to Debian 5 Xen Server, and there were no issues. That said this process should work on all Linux Distributions.

Additionally 
  You must preform the migration to the "SAME" operating system. This means that if you have a CentOS 5.6 Xen Classic Image you must go to a CentOS 5.6 Xen Server Image. If you attempt a migration to an older or new Operating system, it will **FAIL**

Lastly 
  While it is not 100% Necessary to do, I do recommend that you preform all of the necessary backport patching and system updates before attempting the migration. This should be done on both the Origin and Destination servers.

--------------

If you are ready to begin the migration process, Simply download the script and begin the migration process. This script will allow you to seamlessly migrate your Server with very few steps. Please note that the script assumes, you have already created an image of your Xen Classic Server. If you have not created an image of your server, please do so now. This can be accomplished from the Cloud Control Panel.

This will make the script executable :

.. code-block:: bash

    chmod +x xc2xs.sh

Now you can run the script with :

.. code-block:: bash

    ./xc2xs.sh

This script is completely interactive. simply run it and follow the prompts. While migrating it will let you know what it is doing, but be patient, depending on the size of the "Source" instance this operation could take a while.

--------

Please let me know if you have any questions.
