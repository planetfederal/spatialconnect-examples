const API_URL = 'http://localhost:3456/';

let api = {
  getForm(formID) {
    return fetch(API_URL + 'forms/' + formID)
      .then((response) => response.json());
  },
  saveForm(formID, formData) {
    let body = {
      'formID': formID,
      'data': formData
    };
    return fetch(API_URL + 'formData', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(body)
    });
  }
};

export default api;