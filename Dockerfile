FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy the cat website static files into nginx's serve directory
COPY site/index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
