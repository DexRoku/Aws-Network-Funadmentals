# Aws-Network-Funadmentals



# Coffee Shop VPC Architecture - Step by Step

## Your Coffee Shop Application Components

**Frontend:** React app (customers browse and order coffee)
**Backend API:** Node.js server (handles orders, payments, inventory)
**Database:** MySQL (stores customer data, orders, coffee inventory)
**Images:** S3 bucket (coffee photos, logos)

## Step 1: Create Your VPC (The Building)

```
VPC Name: CoffeeShop-VPC
IP Range: 10.0.0.0/16 (gives you 65,536 IP addresses)
```

Think of this as renting an entire floor in a building. The 10.0.0.0/16 is like your floor number - it's your private address space.

## Step 2: Create Subnets (Divide Into Rooms)

### Public Subnet (The Storefront)
```
Name: CoffeeShop-Public-Subnet
IP Range: 10.0.1.0/24 (256 addresses)
Purpose: Houses your load balancer (the cashier counter)
```

### Private Subnet (The Kitchen & Office)
```
Name: CoffeeShop-Private-Subnet
IP Range: 10.0.2.0/24 (256 addresses)
Purpose: Houses your backend servers (the kitchen where orders are prepared)
```

### Database Subnet (The Vault)
```
Name: CoffeeShop-DB-Subnet
IP Range: 10.0.3.0/24 (256 addresses)
Purpose: Houses your database (the secure office where records are kept)
```

## Step 3: Set Up the Internet Gateway (Main Entrance)

```
Name: CoffeeShop-IGW
Attached to: CoffeeShop-VPC
```

This is like the main door to your coffee shop. Without it, no customers can reach you from the internet.

## Step 4: Configure Route Tables (Directions)

### Public Route Table
```
Routes:
- 10.0.0.0/16 → Local (internal traffic stays inside)
- 0.0.0.0/0 → Internet Gateway (everything else goes to internet)

Associated with: Public Subnet
```

### Private Route Table
```
Routes:
- 10.0.0.0/16 → Local (can talk to other parts of your VPC)
- 0.0.0.0/0 → NAT Gateway (for software updates, but no inbound access)

Associated with: Private Subnet, DB Subnet
```

## Step 5: Deploy Your Application

### In Public Subnet:
- **Application Load Balancer** (ALB)
  - Acts like your cashier counter
  - Customers connect here first
  - Distributes orders to your backend servers

### In Private Subnet:
- **EC2 Instances** running your Node.js API
  - Like your baristas working in the kitchen
  - Customers can't directly reach them
  - They receive orders through the load balancer

### In Database Subnet:
- **RDS MySQL Database**
  - Like your secure office filing cabinet
  - Only your backend servers can access it
  - Completely isolated from the internet

## Step 6: Set Up Security Groups (Bouncers)

### Load Balancer Security Group
```
Inbound Rules:
- Port 80 (HTTP) from 0.0.0.0/0 (allow all customers)
- Port 443 (HTTPS) from 0.0.0.0/0 (secure customers)

Outbound Rules:
- Port 3000 to Backend Security Group (forward to kitchen)
```

### Backend Security Group
```
Inbound Rules:
- Port 3000 from Load Balancer Security Group only
- Port 22 (SSH) from your IP only (for maintenance)

Outbound Rules:
- Port 3306 to Database Security Group (talk to database)
- Port 80/443 to 0.0.0.0/0 (for API calls to payment processors)
```

### Database Security Group
```
Inbound Rules:
- Port 3306 from Backend Security Group only

Outbound Rules:
- None needed (database doesn't initiate connections)
```

## The Customer Journey

1. **Customer visits:** `www.coffeeshop.com`
2. **DNS resolves to:** Load Balancer in Public Subnet
3. **Load Balancer receives request:** "Show me the menu"
4. **Load Balancer forwards to:** Backend server in Private Subnet
5. **Backend queries:** Database in DB Subnet for coffee menu
6. **Response flows back:** DB → Backend → Load Balancer → Customer

## Why This Architecture Works

**Security:** Each layer only accepts traffic from the layer above it
**Scalability:** Add more backend servers behind the load balancer
**Reliability:** If one backend server fails, others keep serving
**Maintenance:** Update servers without exposing them to internet attacks

## What Happens If...

**A hacker tries to attack your database directly?**
- Impossible! Database subnet has no internet access and only accepts connections from backend servers

**Your backend server needs to download updates?**
- Goes through NAT Gateway for outbound internet access, but no inbound access allowed

**You need to add more capacity during busy hours?**
- Spin up more EC2 instances in private subnet, load balancer automatically distributes traffic

## Next Steps: Hands-On Practice

1. Create this VPC architecture in AWS
2. Deploy a simple Node.js "Hello Coffee" API
3. Set up the load balancer and test the flow
4. Add RDS database and connect your API
5. Test security by trying to access components directly

This is real-world AWS architecture used by thousands of production applications!