# Notes to self

I've got a function that will parse well behaved list items. At least well enough. I'll have to build up a list of units of measure, but that still leaves cases like "3 eggs". 

I've got a `potato_parser` function that does not yet handle such cases. It should also probably be renamed. 

I also have too much duplicate code in here between the two parsers. I should refactor the code so there's a check for units, then select one of two parsers, or one parser that takes a "units" flag. 

Time to take a break.
playlist: https://www.youtube.com/watch?v=0cBWVqWEewI&list=PLnD5b8flj1eniL0rENXXmuQc2G9oxla3n

Oct 25:
I can take a url and spit out a data frame that separates quantities (as characters), units, and ingredients.

I should add some functionality to handle the quantities properly (e.g. identifying fractional units and converting to decimal)

I should also find a way to standardize ingredients. (e.g. to match "crushed red pepper flakes" and "red pepper flakes") as well as separating "onions, sliced" into [ingredient, notes].

Nov 1:
First off, I should go back over the notes to self above and resolve them!
But here's what I've done today and some thoughts on how I might go forward:
I've got a `get_quantity` function that will pull the quantities out of list item (e.g. "3 cans of broth" becomes 3.0) and handles fractions. I might come across new and exotic fractions, but I think it'll handle things for now. 

A couple sites that were helpful:
* https://utf8-chartable.de/unicode-utf8-table.pl?utf8=dec
* https://cloford.com/resources/charcodes/utf-8_number-forms.htm

So, what's next? I still have to pull out units (which might be weird in some cases like "5 (13.75 ounce) cans"). Once I've got that, it should be easy to parse out the ingredient so I can convert my list into an nx3 dataframe. 

Then there's the sorting. I'll need to sort based on more-or-less standardized ingredient names. I might need to account for things like "flour" vs "whole wheat flour" vs "all purpose flour". But I don't want to have too many special categories if I can avoid it.

Good accomplishment for today!
