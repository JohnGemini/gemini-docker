#!/bin/bash
sed -i '/    from django.contrib.auth.models import User/a except:\n    from django.contrib.auth.models import User' /usr/local/lib/python2.7/dist-packages/registration/models.py
sed -i '/    create_inactive_user = transaction.commit_on_success(create_inactive_user)/c\    create_inactive_user = transaction.atomic(create_inactive_user)' /usr/local/lib/python2.7/dist-packages/registration/models.py
sed -i '/isatty/s/^/#/' /usr/local/lib/python2.7/dist-packages/django/contrib/auth/management/commands/createsuperuser.py
sed -i '/Not running in a TTY/s/^/#/' /usr/local/lib/python2.7/dist-packages/django/contrib/auth/management/commands/createsuperuser.py
sed -i '/        self.connection$/c\        self.ensure_connection()' /usr/local/lib/python2.7/dist-packages/kombu/connection.py
cat <<EOF | patch -p0 -d/
--- ./asynpool.py
+++ /usr/local/lib/python2.7/dist-packages/celery/concurrency/asynpool.py
@@ -709,10 +709,10 @@
                     fileno_to_inq.pop(fd, None)
                     active_writes.discard(fd)
                     all_inqueues.discard(fd)
-                    hub_remove(fd)
             except KeyError:
                 pass
         self.on_inqueue_close = on_inqueue_close
+        self.hub_remove = hub_remove

         def schedule_writes(ready_fds, curindex=[0]):
             # Schedule write operation to ready file descriptor.
@@ -1217,6 +1217,7 @@
             if queue:
                 for sock in (queue._reader, queue._writer):
                     if not sock.closed:
+                        self.hub_remove(sock)
                         try:
                             sock.close()
                         except (IOError, OSError):
EOF
cat <<EOF >/etc/sudoers.d/10-gocloud-www-data
# Created by gocloud
# User rules for www-data
www-data ALL=(ALL) NOPASSWD:ALL
EOF
