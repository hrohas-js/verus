import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi'
import { Ripple } from 'vuetify/directives'

export const vuetify = createVuetify({
  directives: {
    Ripple,
  },
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: { mdi },
  },
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#4CAF50',
          secondary: '#1976D2',
          surface: '#FFFFFF',
        },
      },
    },
  },
})

export default vuetify
