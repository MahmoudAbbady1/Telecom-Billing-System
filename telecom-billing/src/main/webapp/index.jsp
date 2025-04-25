<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>T3mya - Billing Management System</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <style>
            :root {
                --primary-color: #3498db;
                --secondary-color: #2c3e50;
                --accent-color: #e74c3c;
            }

            html, body {
                height: 100%;
            }

            body {
                margin: 0;
                display: flex;
                flex-direction: column;
                min-height: 100vh;
            }

            main {
                flex-grow: 1;
            }

            .hero-section {
                background: linear-gradient(135deg, var(--secondary-color) 0%, var(--primary-color) 100%);
                color: white;
                padding: 5rem 0;
                position: relative;
                overflow: hidden;
            }
            .hero-section {
                min-height: 78.3vh;
                display: flex;
                align-items: center;
                background: linear-gradient(135deg, var(--secondary-color) 0%, var(--primary-color) 100%);
                color: white;
                padding: 5rem 0;
                position: relative;
                overflow: hidden;
            }


            .feature-icon {
                font-size: 2.5rem;
                color: var(--primary-color);
                margin-bottom: 1rem;
            }

            .login-card {
                box-shadow: 0 10px 30px rgba(0,0,0,0.1);
                border: none;
                border-radius: 10px;
            }

            .btn-primary {
                background-color: var(--primary-color);
                border-color: var(--primary-color);
            }

            .btn-primary:hover {
                background-color: #2980b9;
                border-color: #2980b9;
            }

            .nav-pills .nav-link.active {
                background-color: var(--primary-color);
            }

            .floating-shapes {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                overflow: hidden;
                z-index: 0;
            }

            .shape {
                position: absolute;
                opacity: 0.1;
                border-radius: 50%;
            }
        </style>
    </head>

    <body>

        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark" style="background-color: var(--secondary-color);">
            <div class="container">
                <a class="navbar-brand fw-bold" href="#">
                    <i class="fas fa-satellite-dish me-2"></i>T3mya Egypt
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>

            </div>
        </nav>

        <!-- Main Content -->
        <main>
            <!-- Hero Section -->
            <section class="hero-section">
                <div class="floating-shapes">
                    <div class="shape" style="width: 300px; height: 300px; background: white; top: -50px; right: -50px;"></div>
                    <div class="shape" style="width: 200px; height: 200px; background: var(--accent-color); bottom: -30px; left: -30px;"></div>
                </div>
                <div class="container position-relative">
                    <div class="row align-items-center">
                        <div class="col-lg-6">
                            <h1 class="display-4 fw-bold mb-4">Billing System Mangment For T3mya Egypt</h1>
                            <p class="lead mb-4">Automate billing processes for telecom billing.</p>

                        </div>
                        <div class="col-lg-6 mt-5 mt-lg-0">
                            <div class="card login-card">
                                <div class="card-body p-4">
                                    <h4 class="card-title text-center mb-4">Sign In</h4>
                                    <c:if test="${not empty error}">
                                        <div class="alert alert-danger">${error}</div>
                                    </c:if>
                                    <form action="${pageContext.request.contextPath}/login" method="post">
                                        <div class="mb-3">
                                            <label for="username" class="form-label">Username</label>
                                            <input type="text" class="form-control" id="username" name="username" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="password" class="form-label">Password</label>
                                            <input type="password" class="form-control" id="password" name="password" required>
                                        </div>
                                        <div class="d-grid">
                                            <button type="submit" class="btn btn-primary">Login</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <!-- Footer -->
        <footer class="py-4 bg-dark text-white">
            <div class="container">
                <div class="row">
                    <div class="col-md-4 mb-4 mb-md-0">
                        <h5><i class="fas fa-satellite-dish me-2"></i>T2mya -Egypt</h5>
                    </div>  
                </div>
                <hr class="my-4 bg-secondary">
                <div class="row">
                    <div class="col-md-6">
                        <p class="mb-0">&copy; 2025 T2mya -Egypt. All rights reserved to ITI.</p>
                    </div>
                </div>
            </div>
        </footer>

        <!-- Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Smooth scrolling for anchor links
            document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                anchor.addEventListener('click', function (e) {
                    e.preventDefault();
                    document.querySelector(this.getAttribute('href')).scrollIntoView({
                        behavior: 'smooth'
                    });
                });
            });

            // Floating shapes animation
            const shapes = document.querySelectorAll('.shape');
            shapes.forEach((shape, index) => {
                const animationDuration = 15 + (index * 5);
                shape.style.animation = `float ${animationDuration}s infinite ease-in-out`;
            });

            const style = document.createElement('style');
            style.textContent = `
                @keyframes float {
                    0%, 100% { transform: translate(0, 0) rotate(0deg); }
                    25% { transform: translate(5%, 5%) rotate(5deg); }
                    50% { transform: translate(10%, 0) rotate(0deg); }
                    75% { transform: translate(5%, -5%) rotate(-5deg); }
                }
            `;
            document.head.appendChild(style);
        </script>
    </body>
</html>
