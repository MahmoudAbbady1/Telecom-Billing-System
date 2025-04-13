<%@page contentType="text/css" pageEncoding="UTF-8"%>        
:root {
--primary-color: #3498db;
--secondary-color: #2c3e50;
--accent-color: #e74c3c;
}

.welcome-hero {
background: linear-gradient(135deg, var(--secondary-color) 0%, var(--primary-color) 100%);
color: white;
padding: 3rem 0;
position: relative;
overflow: hidden;
}

.dashboard-card {
box-shadow: 0 5px 20px rgba(0,0,0,0.1);
border: none;
border-radius: 10px;
transition: transform 0.3s ease;
}

.dashboard-card:hover {
transform: translateY(-5px);
}

.card-icon {
font-size: 2rem;
color: var(--primary-color);
}

.quick-stats {
border-left: 4px solid var(--primary-color);
}

.user-profile {
text-align: center;
}

.profile-avatar {
width: 100px;
height: 100px;
border-radius: 50%;
object-fit: cover;
border: 3px solid white;
box-shadow: 0 3px 10px rgba(0,0,0,0.2);
}

.sidebar {
background-color: var(--secondary-color);
color: white;
min-height: calc(100vh - 56px);
}

.sidebar .nav-link {
color: rgba(255,255,255,0.8);
padding: 0.75rem 1.5rem;
margin-bottom: 0.25rem;
}

.sidebar .nav-link:hover, .sidebar .nav-link.active {
color: white;
background-color: rgba(255,255,255,0.1);
}

.sidebar .nav-link i {
width: 20px;
margin-right: 10px;
text-align: center;
}