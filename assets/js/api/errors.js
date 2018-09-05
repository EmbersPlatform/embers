export class APIError extends Error {
	constructor(err) {
		super(err.response.data.error || 'bad_request');

		this.status = +err.response.status || 400;
		this.error = err.response.data.error || 'bad_request';
		this.message = err.response.data.message || 'Bad request';
		this.data = err.response.data.data || null;
		this.res = err.response.data;

		// HACK: `new APIError instanceof APIError === false`, so we can check whether the error is
		// a "normal" one or an instance of APIError with this. If there's a cleaner solution out there
		// please feel free to apply it here, thanks
		this.instanceOfApiError = true;
	}
};