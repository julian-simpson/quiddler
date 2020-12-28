module.exports = {
  purge: [],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      'sans': ['Roboto', 'Helvetica', 'Arial', 'sans-serif']
    },  

    extend: {
      boxShadow: {
        'dark':  '0 25px 50px -5px rgba(0, 0, 0, 0.9), 0 10px 20px -5px rgba(0, 0, 0, 0.9)'
      },
      fontFamily: {
        card: 'Cinzel'
      },
    },
  },
  variants: {
    extend: {
      borderWidth: ['first'],
      margin: ['first', 'last'],
    },
  },
  plugins: [],
}
