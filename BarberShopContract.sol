// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BarberShopContract {
    address public owner;

    // Struct to represent a staff member
    struct Staff {
        string fullName;
        uint workingDaysPerWeek;
        bool available;
        mapping(string => bool) servicesOffered;
        mapping(string => uint) serviceDurations;
        mapping(string => uint) servicePrices;
        mapping(string => uint) earningsByService;
        string qualifications; // Added field for qualifications
        string areasOfExpertise;
        uint totalEarnings;
    }
   
   // Mapping to store staff members
    mapping(address => Staff) public staffRegistry;

    // Struct to represent a client
    struct Client {
        string name;
        string service;
        int phone;
            }

    // Mapping to store clients
    mapping(address => Client) public clients;


    // Struct to represent an appointment
    struct Appointment {
        address clientAddress;
        address staffAddress;
        string service;
        uint timestamp; // You can use the timestamp for scheduling
        bool accepted;
    }

    // Mapping to store appointments
    mapping(uint => Appointment) public appointments;

    // Event to notify about appointment status update
    event AppointmentStatusUpdated(uint indexed appointmentId, bool accepted);

   // Struct to represent a service execution
    struct ServiceExecution {
        address staffAddress;
        address clientAddress;
        string service;
        uint duration;
        uint timestamp;
    }

    // Mapping to store service executions
    mapping(uint => ServiceExecution) public serviceExecutions;

    // Struct to represent a transaction
    struct Transaction {
        address payer; // Client who made the payment
        address staffAddress;
        string service;
        uint amount;
        uint timestamp;
    }

    // Mapping to store transactions
    mapping(uint => Transaction) public transactions;


    // Struct to represent a rating and feedback
    struct RatingAndFeedback {
        address clientAddress;
        address staffAddress;
        string service;
        uint rating; // Assuming a numerical rating scale
        string feedback;
        uint timestamp;
    }

    // Mapping to store ratings and feedback
    mapping(uint => RatingAndFeedback) public ratingsAndFeedback;

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }
    // Event to notify about appointment booking
    event AppointmentBooked(uint indexed appointmentId, address indexed clientAddress, address indexed staffAddress, string service, uint timestamp);
    // Function for clients to browse staff availability and book appointments
    function bookAppointment(address staffAddress, string memory service, uint timestamp) public {
        require(staffRegistry[staffAddress].available, "Staff member is not available at the moment");

        // Check if the selected service is offered by the staff
        require(staffRegistry[staffAddress].servicesOffered[service], "Selected service is not offered by this staff member");

        // Check for double bookings
        require(appointments[timestamp].clientAddress == address(0), "Slot is already booked");

        // Create a new appointment
        uint appointmentId = uint(keccak256(abi.encodePacked(msg.sender, staffAddress, service, timestamp)));
        appointments[appointmentId] = Appointment({
            clientAddress: msg.sender,
            staffAddress: staffAddress,
            service: service,
            timestamp: timestamp,
            accepted: false
        });

        // Emit an event to notify about the appointment booking
        emit AppointmentBooked(appointmentId, msg.sender, staffAddress, service, timestamp);
    }


    // Function to add a new staff member (onlyOwner can call this)
    function addStaffMember(address staffAddress, string memory fullName, uint workingDaysPerWeek) public onlyOwner {
    Staff storage newStaff = staffRegistry[staffAddress];
    newStaff.fullName = fullName;
    newStaff.workingDaysPerWeek = workingDaysPerWeek;
    newStaff.available = true;}

    // Function to remove a staff member (onlyOwner can call this)
    function removeStaffMember(address staffAddress) public onlyOwner {
        delete staffRegistry[staffAddress];
    }

    // Event to notify clients or perform other necessary actions
    event StaffAvailabilityUpdated(address indexed staffAddress, bool newAvailability);

    // Function for the owner to set working hours and availability for a staff member
    function setStaffAvailability(address staffAddress, bool newAvailability) public onlyOwner {
        staffRegistry[staffAddress].available = newAvailability;
        // Emit the event to notify clients or perform other necessary actions
        emit StaffAvailabilityUpdated(staffAddress, newAvailability);
    }
    

    // Event to notify clients about updated services
    event ServicesUpdated(address indexed staffAddress, string service, uint price, uint duration);
    // Function for the owner to specify services offered by a staff member
    function specifyServicesOffered(
        address staffAddress,
        string memory service,
        uint price,
        uint duration
    ) public onlyOwner {
        Staff storage staff = staffRegistry[staffAddress];

        // Update or add the service details
        staff.servicesOffered[service] = true;
        staff.servicePrices[service] = price;
        staff.serviceDurations[service] = duration;
        // Emit an event to notify clients about the updated services
        emit ServicesUpdated(staffAddress, service, price, duration);
}
    // Event to notify earnings update
    event EarningsUpdated(address indexed staffAddress, string service, uint earnings);
 
    // Function to record earnings when a service is provided
    function recordEarnings(
        address staffAddress,
        string memory service,
        uint duration // Assuming the duration of the service is passed
    ) public {
        Staff storage staff = staffRegistry[staffAddress];

        // Ensure the service is offered by the staff
        require(staff.servicesOffered[service], "Service is not offered by this staff member");

        // Calculate earnings based on the service price and duration
        uint earnings = (staff.servicePrices[service] * duration) / 60; // Assuming duration is in minutes

        // Update earnings for the service and total earnings for the staff
        staff.earningsByService[service] += earnings;
        staff.totalEarnings += earnings;

        // Emit an event to notify about the earnings update
        emit EarningsUpdated(staffAddress, service, earnings);
    }

    // Function for the owner to accept or reject an appointment
    function manageAppointment(uint appointmentId, bool accept) public onlyOwner {
        Appointment storage appointment = appointments[appointmentId];

        // Ensure the appointment exists
        require(appointment.clientAddress != address(0), "Appointment does not exist");

        // Ensure the appointment is not already accepted or rejected
        require(!appointment.accepted, "Appointment status already updated");

        // Update the appointment status
        appointment.accepted = accept;

        // Emit an event to notify about the appointment status update
        emit AppointmentStatusUpdated(appointmentId, accept);
    }

    // Event to notify about staff profile update
    event StaffProfileUpdated(address indexed staffAddress, string qualifications, string areasOfExpertise);
    // Function for the owner to manage staff profile details
    function setStaffProfile(
        address staffAddress,
        string memory qualifications,
        string memory areasOfExpertise
    ) public onlyOwner {
        Staff storage staff = staffRegistry[staffAddress];

        // Update staff profile details
        staff.qualifications = qualifications;
        staff.areasOfExpertise = areasOfExpertise;

        // Emit an event to notify about the staff profile update
        emit StaffProfileUpdated(staffAddress, qualifications, areasOfExpertise);
    }

    // Event to notify about staff availability update request
    event StaffAvailabilityUpdateRequested(address indexed staffAddress, bool newAvailability);
    // Function for staff members to request availability updates
    function requestAvailabilityUpdate(bool newAvailability) public {
        Staff storage staff = staffRegistry[msg.sender];

        // Update staff's availability based on the request
        staff.available = newAvailability;

        // Emit an event to notify about the availability update request
        emit StaffAvailabilityUpdateRequested(msg.sender, newAvailability);
    }

       // Event to notify about service execution
    event ServiceExecuted(
        uint indexed executionId,
        address indexed staffAddress,
        address indexed clientAddress,
        string service,
        uint duration
    );


    // Function for staff members to execute a service and record details
    function executeService(address clientAddress, string memory service, uint duration) public {
        Staff storage staff = staffRegistry[msg.sender];

        // Ensure the service is offered by the staff
        require(staff.servicesOffered[service], "Service is not offered by this staff member");

        // Record details of the service execution
        uint executionId = uint(keccak256(abi.encodePacked(msg.sender, clientAddress, service, block.timestamp)));
        serviceExecutions[executionId] = ServiceExecution({
            staffAddress: msg.sender,
            clientAddress: clientAddress,
            service: service,
            duration: duration,
            timestamp: block.timestamp
        });

        // Emit an event to notify about the service execution
        emit ServiceExecuted(executionId, msg.sender, clientAddress, service, duration);
    }

    // Event to notify about transaction recording
    event TransactionRecorded(uint indexed transactionId, address indexed payer, address indexed staffAddress, string service, uint amount, uint timestamp);

    // Function to process a payment and record the transaction
    function processPayment(address staffAddress, string memory service, uint amount) public {
        // Check if the staff member is valid
        require(staffRegistry[staffAddress].workingDaysPerWeek > 0, "Invalid staff member");

        // Check if the service is offered by the staff
        require(staffRegistry[staffAddress].servicesOffered[service], "Selected service is not offered by this staff member");

        // Record the transaction details
        uint transactionId = uint(keccak256(abi.encodePacked(msg.sender, staffAddress, service, amount, block.timestamp)));
        transactions[transactionId] = Transaction({
            payer: msg.sender,
            staffAddress: staffAddress,
            service: service,
            amount: amount,
            timestamp: block.timestamp
        });

        // Emit an event to notify about the transaction
        emit TransactionRecorded(transactionId, msg.sender, staffAddress, service, amount, block.timestamp);
    }
    
    // Event to notify about rating and feedback submission
    event RatingAndFeedbackSubmitted(uint indexed feedbackId, address indexed clientAddress, address indexed staffAddress, string service, uint rating, string feedback, uint timestamp);

    // Function for clients to provide ratings and feedback
    function provideRatingAndFeedback(address staffAddress, string memory service, uint rating, string memory feedback) public {
        // Check if the staff member is valid
        require(staffRegistry[staffAddress].workingDaysPerWeek > 0, "Invalid staff member");

        // Check if the service is offered by the staff
        require(staffRegistry[staffAddress].servicesOffered[service], "Selected service is not offered by this staff member");

        // Record the rating and feedback details
        uint feedbackId = uint(keccak256(abi.encodePacked(msg.sender, staffAddress, service, rating, feedback, block.timestamp)));
        ratingsAndFeedback[feedbackId] = RatingAndFeedback({
            clientAddress: msg.sender,
            staffAddress: staffAddress,
            service: service,
            rating: rating,
            feedback: feedback,
            timestamp: block.timestamp
        });

        // Emit an event to notify about the submitted rating and feedback
        emit RatingAndFeedbackSubmitted(feedbackId, msg.sender, staffAddress, service, rating, feedback, block.timestamp);
    }    
}
