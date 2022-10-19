from pydexcom import Dexcom
dexcom = Dexcom("alix12488", "ab6407789") # add ous=True if outside of US
bg = dexcom.get_current_glucose_reading()
bg.value
print(bg.value)