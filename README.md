This OCurrent pipeline will monitor a GitHub repository and deploy the
Ansible Playbooks that it finds there.

The repository must contain a file `configuration.sexp`, which the
pipeline reads.  The minimal configuration file is given below:

```
((playbooks(((name playbook.yml)))))
```

In this example, a single playbook called `playbook.yml` is monitored
for changes and deployed with `ansible-playbook playbook.yml`.  In this
minimal case, an `ansible.cfg` file should be present in the repository
to give the location of the host inventory file.

Alternatively, an inventory can be specified as shown below, resulting in
`ansible-playbook -i hosts playbook.yml`.

```
((playbooks(((name playbook.yml)(inventory hosts)))))
```

In this more complete example, `deps` indicates a list of files which
the playbook depends upon.  The playbook and all the dependencies are
hashed and if there is any change the playbook is redeployed.  Recurrent
deployments can be specified using `validity`, which indicates the number
of days between deployments.  The hosts targeted can be limited with the
`limit` directive.

```
((playbooks (
  (
   (name update-something-else.yml)
   (deps (roles/apt/tasks/main.yml))
  )
  (
   (name update.yml)
  )
  (
   (name playbook.yml)
   (validity 7)
   (inventory hosts)
   (limit (host1 host2))
   (deps (roles/ubuntu/tasks/main.yml))
  )
)))
```

# Deployment

Create the GitHub application using this [link](https://github.com/settings/apps/new?name=Ocurrent%20Configurator&url=http:%2F%2Fi5.102.169.176&public=false&webhook_active=true&webhook_url=http:%2F%2F5.102.169.176/webhooks/github&callback_url=http://5.102.169.176:8080/login&device_flow_enabled=1&contents=read&pull_requests=write&statuses=write&repository_hooks=write&events[]=push&events[]=pull_request).

Add a webhook secret: e.g. `openssl rand -base64 32`

Use the `Makefile` to build a Docker image.  The `docker-compose.yml`
gives a sample deployment, which can be deployed using `make up`.

