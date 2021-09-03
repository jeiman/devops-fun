'use strict';
/**
 * Note: This can be done easily using the GitHub Actions step
 * Link: https://github.com/marketplace/actions/invalidate-cloudfront
 * If you want to avoid writing lambda, you can use the above action
 */
// CONFIGURATION
let aws = require('aws-sdk');
// let s3 = new aws.S3();
var CloudFrontID = process.env.DISTRIBUTION_ID;
let cloudfront = new aws.CloudFront();

// S3
exports.handler = (event, context, callback) => {
	const bucket = event.Records[0].s3.bucket.name;
	const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
	console.log('Bucket items: ', key);

	// Cloudfront
	const params = {
		DistributionId: CloudFrontID,
		InvalidationBatch: {
			CallerReference: new Date().getTime().toString(),
			Paths: {
				Quantity: 1,
				Items: [
					'/*',
				]
				// Items: [
				// 	'/'+key,
				// ]
			}
		}
	};
	
	// Only trigger the invalidation if there's a change on index.html, but invalidate all of the files. 
	// This is to ensure it does not trigger multiple invalidations, which in turn, will use up our 1000 invalidations in a month.
	if (key === 'index.html') {
		cloudfront.createInvalidation(params, function(err, data) {
			let message;
			if (err) {
				console.log(err, err.stack);
				message = 'ERROR: Failed to invalidate object: s3://'+bucket+'/'+key;
				console.log(message);
			} else {
				message = 'Object invalidated successfully: s3://'+bucket+'/'+key;
				console.log(message);
			}
		});
	}
	
};