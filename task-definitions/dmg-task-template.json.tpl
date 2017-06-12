[
    {
        "name": "${image-name}",
        "image": "matsskoglund/house-demo:${image_tag}",
        "cpu": 15,
        "memory": 300,
        "links": [],
        "portMappings": [
            {
                "containerPort": 80,
                "hostPort": 0,
                "protocol": "tcp"
            }
        ],
        "essential": true,
        "entryPoint": [],
        "command": [],        
        "volumesFrom": [],
       "logConfiguration": {
       "logDriver": "awslogs",
       "options": {
        "awslogs-group": "${log-group}",
        "awslogs-region": "eu-west-1",
        "awslogs-stream-prefix": "${log-stream}"
        }
      }
    }
]