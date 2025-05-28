import random
from random import randint, choice
import requests
import json
import os

# Fetch customer data from the API
def get_customer_data():
    try:
        response = requests.get("http://localhost:8080/telecom-billing/api/customers")
        response.raise_for_status()
        data = response.json()
        
        # Handle both single customer and list of customers
        customers = data if isinstance(data, list) else [data] if isinstance(data, dict) and "customer" in data else data.get("customers", [])
        
        # Extract phone numbers, roaming quotas, data service presence, and status
        customer_info = {}
        for item in customers:
            customer = item.get("customer", item)
            if isinstance(customer, dict) and "phone" in customer and customer.get("status") == "ACTIVE":
                phone = customer["phone"]
                # Fetch roaming quota and check for data service
                roaming_quota = 0
                has_data_service = False
                rate_plan = item.get("ratePlan", {})
                service_packages = rate_plan.get("servicePackages", [])
                for service in service_packages:
                    if service.get("serviceType") == "VOICE" and service.get("serviceNetworkZone") == "ROAMING":
                        roaming_quota = service.get("qouta", 0)
                    if service.get("serviceType") == "DATA":
                        has_data_service = True
                customer_info[phone] = {
                    "roaming_quota": roaming_quota,
                    "has_data_service": has_data_service
                }
        
        return customer_info
    except requests.RequestException as e:
        print(f"Error fetching customer data from API: {e}")
        print("Using fallback phone numbers with default roaming quota of 50 minutes and no data service.")
        return {
            phone: {"roaming_quota": 50, "has_data_service": False} for phone in [
                "+201611223320", "+201622334408", "+201687654325", "+201656789028",
                "+201667809035", "+201645378903", "+201604919109", "+201649191518",
                "+201649154514", "+201695959930", "+201649177767", "+201649195501",
                "+201664565811", "+201611111113", "+201645454532", "+201612789009",
                "+201604912015"
            ]
        }

# Get customer data
customer_data = get_customer_data()
phone_numbers = list(customer_data.keys())

# Ensure we have at least one phone number
if not phone_numbers:
    print("No phone numbers available to generate CDRs.")
    exit(1)

# Common websites for data usage
websites = [
    "http://www.google.com",
    "http://www.facebook.com",
    "http://www.youtube.com",
    "http://www.instagram.com",
    "http://www.whatsapp.com",
    "http://www.twitter.com",
    "http://www.linkedin.com",
    "http://www.netflix.com",
    "http://www.amazon.com",
    "http://www.ebay.com"
]

# Create CDRs directory if it doesn't exist
os.makedirs("./CDRs", exist_ok=True)

# Generate 1000 CDRs for each phone number as dial_a
for dial_a in phone_numbers:
    cdrs = []
    roaming_quota = customer_data[dial_a]["roaming_quota"]
    has_data_service = customer_data[dial_a]["has_data_service"]
    total_cdrs = 1000
    
    # Define service distribution
    if has_data_service:
        # 40% Data (400), 30% Voice (300), 20% SMS (200), 10% Roaming Voice (100)
        service_counts = {1: 300, 2: 200, 3: 400, 4: 100}  # 1=Voice, 2=SMS, 3=Data, 4=Roaming Voice
    else:
        # 50% Voice (500), 40% SMS (400), 10% Roaming Voice (100)
        service_counts = {1: 500, 2: 400, 4: 100}
    
    # Generate exact number of each service type
    service_list = []
    for service, count in service_counts.items():
        service_list.extend([service] * count)
    random.shuffle(service_list)  # Shuffle to distribute services randomly
    
    roaming_calls_generated = 0
    roaming_minutes_used = 0
    
    for service in service_list:
        is_roaming = (service == 4)  # Roaming Voice
        
        # Select dial_b
        if is_roaming:
            dial_b = f"+{random.randint(100, 999)}{random.randint(1000000, 9999999)}"
            roaming_calls_generated += 1
        else:
            dial_b_candidates = [n for n in phone_numbers if n != dial_a]
            dial_b = choice(dial_b_candidates) if dial_b_candidates else f"+201{randint(1000000, 9999999)}"
        
        if service in [1, 4]:  # Voice or Roaming Voice
            duration = randint(10, 180)  # 10-180 seconds
            if is_roaming:
                if roaming_minutes_used + duration > roaming_quota:
                    duration = max(0, roaming_quota - roaming_minutes_used)
                roaming_minutes_used += duration
            volume = str(duration)
            external = "0"
        elif service == 2:  # SMS
            duration = randint(1, 3)
            volume = str(duration)
            external = "0"
        else:  # Data
            dial_b = choice(websites)
            duration = randint(1, 10) * 1024 * 1024  # 1-10 MB
            volume = str(duration)
            external = str(randint(5, 50))
        
        # Generate time
        hour = randint(8, 22) if random.random() < 0.8 else randint(0, 23)  # 80% daytime
        minute = randint(0, 59)
        second = randint(0, 59)
        time_str = f"{hour:02d}:{minute:02d}:{second:02d}"
        
        cdrs.append(f"{dial_a},{dial_b},{service if service != 4 else 1},{volume},{time_str},{external}")
    
    # Save to file
    filename = f"./CDRs/CDR_{dial_a.replace('+', '')}.csv"
    with open(filename, "w") as f:
        f.write("\n".join(cdrs))

