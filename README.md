# Glam Heel Hangout (GHH)

**Glam Heel Hangout** is a complete fashion-focused eCommerce platform built as a seminar project for the *Software Development 2* course. The application connects shoe enthusiasts with trending models through a modern and seamless user experience. The system includes **mobile and desktop applications** built in **Flutter**, backed by a **.NET Web API** and enhanced by real-time notifications, recommendation systems, and secure payments.

---

##  Features

User Features
- User registration and login functionality
- Display of available products on the home page
- Product filtering by categories (Heels, Loafers, Boots, Flats, or Slippers)
- Product search by name
- Detailed product view with all specifications
- Ability to place an order
- Size selection and adding products to the cart
- Viewing cart contents
- Removing items from the cart
- Adjusting product quantity — the "+" button becomes disabled if the selected size has reached its stock limit
- Auto-filled checkout form with user's full name, email, and phone (editable if the user wants to override these values for the order)
- Leaving product reviews via star rating and viewing the average rating per product
- Viewing a list of notifications about new products and active giveaways
- Receiving real-time popup notifications for new products, active giveaways, winners, and discounts
- Viewing active giveaways, opening participation forms, and confirming participation
- Viewing past giveaways and their winners
- Editing user profile information (profile picture, personal details)
- Changing user password
- Viewing personalized product recommendations on the home page based on favorite products or top-rated ones (if no favorites exist); users can toggle visibility of this section


Admin Features
- Adding new products to the catalog
- Editing existing product details
- Applying discounts: after clicking "Set Discount", the admin sets the discount and saves changes — then returns to the product detail screen and clicks "Save" again to make changes visible on the home page
- Removing an active discount from a product
- Adding new giveaways with custom start and end dates
- Filtering giveaways by All, Active, and Inactive statuses
- Selecting a giveaway winner (only if the giveaway has ended)
- Disabled winner selection if there are no participants, with a clear message shown
- Deleting a giveaway (e.g., if created by mistake or if completed and the winner has already been selected)
- Viewing and managing all orders with filters (by customer or by order status)
- Changing order status to Canceled or Delivered
- Deleting an order if needed



---

##  Technologies Used

| Layer        | Technology                      |
|--------------|----------------------------------|
| Backend      | ASP.NET Core Web API (.NET 6)    |
| ORM          | Entity Framework Core (Code First) |
| Frontend     | Flutter (mobile & desktop)       |
| Database     | SQL Server                       |
| Messaging    | RabbitMQ                         |
| Real-Time    | SignalR                          |
| ML           | ML.NET for recommendation engine |
| Payments     | Stripe                           |

---

##  Getting Started

Follow the steps below to run the project locally.

###  Prerequisites

Ensure you have the following tools installed:

- Docker: For containerizing the backend.
- Visual Studio Code: Recommended for editing and running the frontend (Flutter).
- Flutter: To run the desktop and mobile applications.

---
### Clone the Repository
https://github.com/ajla-zulovic/eGlamHeelHangout.git

###  Environment Variables

- Note on .env File Configuration
After cloning the project, it is required to manually create a .env file in the root (eGlamHeelHangout\eGlamHeelHangout) of the project (where docker-compose.yml file is located).

In this .env file, you must define the following environment variables exactly as shown:

### Stripe__SecretKey=your_stripe_secret_key_here
### Stripe__PublishableKey=your_stripe_publishable_key_here

This step is necessary because the .env file is intentionally excluded from version control via the .gitignore file in order to protect sensitive data such as secret keys.

Running the Backend API
To start the API and other necessary services, navigate to the project's root folder (eGlamHeelHangout\eGlamHeelHangout) and run the following command:

docker-compose up --build


### Running the Desktop Apps

The desktop application is intended for the administrator, who manages the product catalog (adding, editing, and deleting products), views monthly revenue and age group analytics, handles giveaway creation and winner selection, manages customer orders, and can also edit their own profile information through the admin panel.
Navigate to the appropriate folder based on role:

eGlamHeelHangout\eGlamHeelHangout\UI\eglamheelhangout_admin

### Install the necessary dependencies:  
flutter pub get  
Run the application:  
flutter run --dart-define=BASE_URL=http://localhost:7277/ 


Running the Mobile App  
Navigate to the mobile app folder: eGlamHeelHangout\eGlamHeelHangout\UI\eglamheelhangout_mobile

Install dependencies:

flutter pub get
Run the application, if you use emulator -> flutter run --dart-define=BASE_URL=http://10.0.2.2:7277/ --dart-define=SIGNALR_URL=http://10.0.2.2:7277/giveawayHub

If you have the .env file set up, simply run:
flutter run  flutter run --dart-define=BASE_URL=http://10.0.2.2:7277/ --dart-define=SIGNALR_URL=http://10.0.2.2:7277/giveawayHub  --dart-define=Stripe__PublishableKey=yourStripePublishableKey


### Credentials For Testing
Administrator App  
Username: admin  
Password: Admin123!  
Mobile/user App  
Username: user  
Password: User123!

### Testing Payments
To test payment processing, use the following details:  

Card Number: 4242 4242 4242 4242  
Expiration Date: Any future date for example 05/29  
CVC: Any three-digit number for example 123


### License
This project is licensed under the MIT License.

