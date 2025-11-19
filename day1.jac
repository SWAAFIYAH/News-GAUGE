# Node representing a User with username , email and  password


node User {
    has username: str = "";
    has email:str ="";
    has password: str = "";

    can update_user with entry {
        self.username = visitor.username;
        self.email = visitor.email;
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
            new_user = here ++> User(username="default", email = "default",password="default");
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
    has email:str;
    has password: str;

    can update_user with `root entry {
        all_users = [root --> (`?User)];
        user_nodes = [u for u in all_users if u.username == self.username];
        if len(user_nodes) == 0 {
            # Create new user
            new_user = here ++> User(username=self.username, email=self.email, password=self.password);
            grant(new_user[0], level=ConnectPerm);
            report "User registered: " + self.username;
            print(f" user regestered" + self.username);
        } else {
            # Update existing user
            for user in user_nodes {
                user; update_user;
            }
            report "User updated: " + self.username;
            print(f" user updated"+ self.username);
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
    has email:str;

    can login with `root entry {
        all_users = [root --> (`?User)];
        print(f"all users {all_users}");
        user_nodes = [u for u in all_users if u.username == self.username];
        if len(user_nodes) == 0 {
            report "login fail: user not found";
            #print("login field user not found"); #you can remove the comment to test in terminal
        } else {
            for user in user_nodes {
                if user.password == self.password {
                    report "login success for user " + self.username;
                    print("login successfully");
                } else {
                    report "login fail: incorrect password for user " + self.username;
                    print("wrong credentials");
                }
            }
        }
    }
}

# Example entry to register a new user ("must have a user_name , email & password")
#with entry {
    #root spawn update_user(username="newuser", email="abdimalik@254", password="securepass");
#}

# Example entry to login a user (uncomment to test) , #the email is empty because no need for user to enter email on login
#with entry {
    #root spawn login_user(username="newuser",email="", password="securepass"); 
#}





#This node for Topic it contains topic name e.g politics , science and heath

node Topic{
    has topicname : str ="";
    can update_topic with entry{
        self.topicname = visitor.topicname;
        report self;
    }

}
walker visit_topic {

    can visit_topic with `root entry {
        visit [root --> (`?Topic)] else {
            new_topic = here ++> Topic(topicname="default");
            grant(new_topic[0], level=ConnectPerm);
            visit new_topic;
        }
    }
}

walker update_topic(visit_topic){
    has topicname:str;

    can update_topic with `root entry{
        all_topics = [root-->(`?Topic)];

        topic_nodes = [ u for u in all_topics if u.topicname == self.topicname];
        if len(topic_nodes) ==0{
            new_topic = here ++> Topic(topicname=self.topicname);
            grant(new_topic[0] , level=ConnectPerm);
            report "topic created:"+ self.topicname;
            print(f"new_topic created:" +self.topicname);
        }
    }
}

#can uncommment to test
#with entry{
    #root spawn update_topic(topicname="politics");
    #root spawn update_topic(topicname="science");
#}

node Source {
    has source_name: str;
    has domain: str;
    
    
    has political_leaning: str;
}

node Article {
    has article_id: str;
    has title: str;
    has content: str;
    has url: str;
    has publication_date: str;
    has initial_credibility_score: float = 0.5;
    has bias_score: float = 0.0;
    has has_misinformation: bool = false;
}

node Claim {
    has claim_text: str;
    has verifiability: bool;
    has sentiment: str;
}

#the edges to create relationship with node
edge user_interests {           #the interest userhas for a specific topic
    has weight: float = 0.5;
}

edge article_belongs_to_topic {
    has relevance: float = 1.0;
}

edge article_published_by {}

edge user_read_history {
    has read_date: str;
    has time_spent: int;
    has engagement_score: float;
}

edge article_makes_claim {}

edge claim_similarity {
    has similarity_score: float;
    has relationship: str;
}

edge source_trust {
    has trust_level: float;
}

