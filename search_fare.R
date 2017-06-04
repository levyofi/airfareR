
#devtools::install_github('rweyant/googleflights')
library(googleflights)
library(mailR)
google_api_key = "yourkey"
set_apikey(google_api_key)

#desired characteristics of flight
min_connection_in_hours = 4 #desired maximum duration for a connection
max_connection_in_hours = 7 #desired minimum duration for a connection
max_price = 5000 #desired price

#details for email receipt
email_address = "1234@gmail.com" 
email_username = "1234"
email_pass = "yourpassword" #your password (be careful!)


while (TRUE){    #constantly look for flights (make sure to not exceed the maximum request that are free every day (I think 50)
	#an example of a search - please change depending on your case (many parameters are not mandatory too) 
	results = search(origin='PHX',dest='TLV',startDate='2017-06-14',returnDate='2017-07-11', maxStops=3,  adultCount=2, childCount=2, refundable = "false", permittedCarrier="UA", maxPrice="USD6600")
	print(paste("search done on:", Sys.time()))
	for (i in 1:length(results$trips$tripOption)) {
		
		#count the number of flights
		n_go_flights = length(results$trips$tripOption[[i]]$slice[[1]]$segment)
		n_return_flights = length(results$trips$tripOption[[i]]$slice[[2]]$segment)
	
		#get total price
		price = results$trips$tripOption[[i]]$saleTotal
		
		
		carriers = results$trips$tripOption[[i]]$slice[[1]]$segment[[1]]$flight$carrier
		flight_numbers = results$trips$tripOption[[i]]$slice[[1]]$segment[[1]]$flight$number
		arr_times = c(results$trips$tripOption[[i]]$slice[[1]]$segment[[1]]$leg[[1]]$arrivalTime)
		dep_times = c(results$trips$tripOption[[i]]$slice[[1]]$segment[[1]]$leg[[1]]$departureTime)
		origins = c(results$trips$tripOption[[i]]$slice[[1]]$segment[[1]]$leg[[1]]$origin)
		destinations = paste(results$trips$tripOption[[i]]$slice[[1]]$segment[[1]]$leg[[1]]$destination)
		
		for (j in 2:n_go_flights){
			if (j==2){
				connection_durations_in_minutes = c(results$trips$tripOption[[i]]$slice[[1]]$segment[[1]]$connectionDuration)			
			} else {
				connection_durations_in_minutes = c(connection_durations_in_minutes, results$trips$tripOption[[i]]$slice[[1]]$segment[[j-1]]$connectionDuration)
			}
			carriers = paste(carriers, results$trips$tripOption[[i]]$slice[[1]]$segment[[j]]$flight$carrier)
			flight_numbers = paste(flight_numbers, results$trips$tripOption[[i]]$slice[[1]]$segment[[j]]$flight$number)
			arr_times = c(arr_times, results$trips$tripOption[[i]]$slice[[1]]$segment[[1]]$leg[[1]]$arrivalTime)
			dep_times = c(dep_times, results$trips$tripOption[[i]]$slice[[1]]$segment[[j]]$leg[[1]]$departureTime)
			origins = c(origins, results$trips$tripOption[[i]]$slice[[1]]$segment[[j]]$leg[[1]]$origin)
			destinations = paste(destinations, results$trips$tripOption[[i]]$slice[[1]]$segment[[j]]$leg[[1]]$destination)
		}
		for (j in 1:n_return_flights){
			if (!exists("connection_durations_in_minutes")){
				connection_durations_in_minutes = c(results$trips$tripOption[[i]]$slice[[2]]$segment[[1]]$connectionDuration)			
			} else if (j>1) {
				connection_durations_in_minutes = c(connection_durations_in_minutes, results$trips$tripOption[[i]]$slice[[2]]$segment[[j-1]]$connectionDuration)
			}
			carriers = paste(carriers, results$trips$tripOption[[i]]$slice[[2]]$segment[[j]]$flight$carrier)
			flight_numbers = paste(flight_numbers, results$trips$tripOption[[i]]$slice[[2]]$segment[[j]]$flight$number)
			arr_times = c(arr_times, results$trips$tripOption[[i]]$slice[[2]]$segment[[1]]$leg[[1]]$arrivalTime)
			dep_times = c(dep_times, results$trips$tripOption[[i]]$slice[[2]]$segment[[j]]$leg[[1]]$departureTime)
			origins = c(origins, results$trips$tripOption[[i]]$slice[[2]]$segment[[j]]$leg[[1]]$origin)
			destinations = paste(destinations, results$trips$tripOption[[2]]$slice[[1]]$segment[[j]]$leg[[1]]$destination)		
		}
		
		if (exists("connection_durations_in_minutes")){
			for (j in 1:length(connection_durations_in_minutes) ){
				duration_hours= connection_durations_in_minutes[j]%/%60
				duration_minutes= connection_durations_in_minutes[j]%%60
				duration_str = sprintf("%02d:%02d", duration_hours, duration_minutes)
				if (j==1){
					connections_str =  duration_str
				} else {
					connections_str = paste(connections_str, duration_str)
				}
			}
		}
		
		price_num = as.numeric(substr(price, 4, nchar(price)))
		analysis = paste(i, ":", price, ", number_of_flights:", n_go_flights, n_return_flights, " carriers:", carriers, ", connection destinations:", destinations, ", connection durations:", connections_str)		
		print(analysis)
		if (price_num<max_price & (max(connection_durations_in_hours)<=max_connection_in_hours) & (min(connection_durations_in_hours)>=min_connection_in_hours)){ # a cheap flight wirh reasonable connection was found!
			send.mail(from = email_address,
			to = email_address, 					
			subject = paste("Found a flight for",price),
			body = analysis,
			smtp = list(host.name = "smtp.gmail.com", port = 465, user.name = email_username, passwd = email_pass, ssl = TRUE),
			authenticate = TRUE,
			send = TRUE)
		}		
	}
	Sys.sleep(1800) #wait 30 minutes between searches to avoid exceeding 50 google queries per day	
}

