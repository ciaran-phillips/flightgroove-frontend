# Frontend code for an Elm & NodeJS flight explorer using the Skyscanner API. 

This is just a personal project I've been using for the purposes of learning a little functional programming.
I started it while Skyscanner were running a #buildWithSkyscanner competition, since working with flights APIs sounded pretty interesting.

* Live application can be found here: [flightgroove.com](http://flightgroove.com).
* Backend code can be found at [github.com/ciaran-phillips/flightgroove-backend](http://github.com/ciaran-phillips/flightgroove-backend).

## So what does this do?

* Shows cheap flights from your location displayed on a map. 
* Shows basic cost of living data and activities / things to do in many destinations.
* Shows cheap flights available from two locations (i.e. to plan meeting up with a friend in a third location).

## So it's ready for use?

* Not really. The flights shown are real, and you can follow the link to book through a third party, but at the moment I 
see better results coming through on Skyscanner's website than I see in their API, and I'm not entirely sure why. Also this thing is
obviously still rather buggy and missing many features.

## Can I build it locally?

If for some reason you want to, you can easily build the frontend locally and mess around with some of the features. 
The backend unfortunately requires API keys for Skyscanner and Expedia to be placed in config.json.
The frontend can be built/ran using the commands below. It should be easy to see what's going on, I didn't reach a point where
this needed Grunt/Gulp etc, so you can see the entire build process by taking a look at the script commands in package.json.

```
npm install
npm run build_assets
npm run build_app
npm run serve
```

The dev server will run on http://localhost:8000.