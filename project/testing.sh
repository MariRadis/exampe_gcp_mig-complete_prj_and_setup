#!/bin/bash

# You can test autoscaling by sending a high volume of requests to the load balancer IP:
ab -n 10000 -c 100 http://your-load-balancer-ip/