-- Add magnets to sides of rectangle
-- Laurence Scotford - October 2013

property num_mags : 6 -- number of magnets per side
set {North, East, South, West} to {1, 2, 3, 4} -- Enumerator for identifying the sides
set the_sides_list to {"North", "East", "South", "West"} -- List of strings for user choice
set corners to {{{-1, -1}, {1, -1}}, {{1, -1}, {1, 1}}, {{1, 1}, {-1, 1}}, {{-1, 1}, {-1, -1}}} -- positions of corner points for each side
set my_mags to {} -- empty list in which magnets will be assembled

-- ask the user for the number of magnets and whether to include corners or not
set err_message to ""
repeat
	try
		set the_result to display dialog "Enter number of magnets per side and choose distribution type:" & err_message default answer num_mags buttons {"Cancel", "Include Corners", "Don't include Corners"}
		set num_mags to text returned of the_result as integer
	on error number err_num
		-- if error is anything other than coercion error then throw it...
		if err_num is not -1700 then error number err_num
		-- …otherwise set number of magnets to zero and try again…
		set num_mags to 0
	end try
	-- if number of magnets is not a positive whole number, try again with error message
	if num_mags > 0 then exit repeat
	set err_message to return & "Please enter a positive whole number!"
end repeat

-- set whether to include corners or not based on user response
set including_corners to button returned of the_result is "Include Corners"

-- calculate number of magnets that will fall between corners-- and number of final magnet before corner
if including_corners then
	set inner_mags to num_mags - 2
else
	set inner_mags to num_mags
end if

-- Get the user to select the sides to apply to and then turn these into list of numeric values
set the_result to choose from list the_sides_list with prompt "Which sides should magnets be applied to?" with multiple selections allowed
set sides to {}
repeat with a_side from 1 to the count of the_sides_list
	if item a_side of the_sides_list is in the_result then copy a_side to end of sides
end repeat

-- create the magnets between corners (if there are any) 
if inner_mags > 0 then
	repeat with mag_count from 1 to inner_mags
		set mag_pos to (2 / (inner_mags + 1)) * mag_count - 1
		if sides contains North then
			set end of my_mags to {mag_pos, -1}
		end if
		if sides contains East then
			set end of my_mags to {1, mag_pos}
		end if
		if sides contains South then
			set end of my_mags to {mag_pos, 1}
		end if
		if sides contains West then
			set end of my_mags to {-1, mag_pos}
		end if
	end repeat
end if

-- now add the corner magnets, if required
if including_corners then
	repeat with side in sides
		-- add the leading corner magnet (clockwise)
		set coords to item 1 of item (side as number) of corners
		if {coords} is not in my_mags then set end of my_mags to coords
		-- if there's more than one magnet per side, add the trailing corner magnet (clockwise)
		if num_mags > 1 then
			set coords to item 2 of item (side as number) of corners
			if {coords} is not in my_mags then set end of my_mags to coords
		end if
	end repeat
end if

-- apply the magnets to the selected shapes
tell application id "OGfl"
	tell front window
		set my_shapes to its selection
		repeat with drawn_object in my_shapes
			if class of drawn_object is shape then
				set magnets of drawn_object to my_mags
			end if
		end repeat
	end tell
end tell
