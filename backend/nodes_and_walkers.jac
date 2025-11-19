# Node representing a User with username and password
node User {
    has username: str = "";
    has password: str = "";

    can update_user with entry {
        self.username = visitor.username;
        self.password = visitor.password;
        report self;
    }

    can login_user with entry {
        if self.username == visitor.username and self.password == visitor.password {
            report "login success for user " + self.username;
        } else {
            report "login fail for user " + self.username;
        }
    }
}

# Base walker to visit or create user nodes
walker visit_user {
    obj __specs__ {
        static has auth: bool = False;  # disable auth for this walker
    }

    can visit_user with `root entry {
        visit [root --> (`?User)] else {
            new_user = here ++> User(username="default", password="default");
            grant(new_user[0], level=ConnectPerm);
            visit new_user;
        }
    }
}

# Walker to update or create user credentials
walker update_user(visit_user) {
    obj __specs__ {
        static has auth: bool = False;
    }

    has username: str;
    has password: str;

    can update_user with `root entry {
        all_users = [root --> (`?User)];
        user_nodes = [u for u in all_users if u.username == self.username];
        if len(user_nodes) == 0 {
            # Create new user
            new_user = here ++> User(username=self.username, password=self.password);
            grant(new_user[0], level=ConnectPerm);
            report "User registered: " + self.username;
        } else {
            # Update existing user
            for user in user_nodes {
                user; update_user;
            }
            report "User updated: " + self.username;
        }
    }
}

# Walker to login users with proper credential check
walker login_user(visit_user) {
    obj __specs__ {
        static has auth: bool = False;
    }

    has username: str;
    has password: str;

    can login with `root entry {
        all_users = [root --> (`?User)];
        user_nodes = [u for u in all_users if u.username == self.username];
        if len(user_nodes) == 0 {
            report "login fail: user not found";
        } else {
            for user in user_nodes {
                if user.password == self.password {
                    report "login success for user " + self.username;
                } else {
                    report "login fail: incorrect password for user " + self.username;
                }
            }
        }
    }
}

# Example entry to register a new user
#with entry {
 #   root spawn update_user(username="newuser", password="securepass");
#}

# Example entry to login a user (uncomment to test)
# with entry {
#     root spawn login_user(username="newuser", password="securepass");
# }