import wrap from '../wrap';
import axios from 'axios';

export default {
  get name() { return 'pi.gy'; },

  upload(formData) {
    return wrap(() => new Promise( (resolve, reject) => {
      axios.create().post('https://pi.gy/api/image', formData)
      .then( res => {
        var data = res.data;
        res.data = {
          files: [
            {
              name: data.image.file_name + '.' + data.image.file_ext,
              size: data.image.file_size,
              url: data.image.url
            }
          ],
          success: data.success
        };
        resolve(res);
      })
      .catch(reject);
    }));
  }
};