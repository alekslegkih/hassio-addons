# ntfy Command Quick Reference

The add-on uses the built-in **ntfy** authentication system.  
User and permission management is performed via the CLI inside the add-on container.

---

## Accessing the Add-on CLI

Via the Home Assistant OS add-on (SSH):

```bash    docker exec -it addon_dc0b8324_ntfy-server /bin/sh

After that, all commands are executed inside the container.

> [!TIP]
> You can always get full help by running:

```bash
    ntfy --help
    ntfy <command> --help
```

---

## Quick List of Common Commands

```bash
    # List users
    ntfy user list

    # Add a user
    # You will be prompted to set a password
    ntfy user add USERNAME

    # Remove a user
    ntfy user remove USERNAME

    # Change a user password
    ntfy user change-pass USERNAME
```

---

> [!TIP]
> By default, the configuration enables **auth-default-access: "deny-all"**.  
> This means access to topics must be explicitly granted.

---

```bash
    # Grant user access to a topic

    # Read and write access:
    ntfy access USERNAME TOPIC read-write

    # Read-only access:
    ntfy access USERNAME TOPIC read-only

    # Publish-only access:
    ntfy access USERNAME TOPIC write-only

    # Deny access to a topic:
    ntfy access USERNAME TOPIC deny

    # Remove all topic permissions for a user
    ntfy access --reset USERNAME TOPIC

    # List all topic access rules
    ntfy access
```

---

## Notes

- All changes are applied **immediately**; restarting the add-on is not required.
- User and access data is stored in the `/config/auth.db` file.
- User management is not available via the Web UI and can only be performed through the CLI.
