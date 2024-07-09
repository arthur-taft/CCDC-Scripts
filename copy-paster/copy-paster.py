import pyautogui
import tkinter
import time

time.sleep(5)

clipboard_content = tkinter.Tk().clipboard_get()

pyautogui.write(clipboard_content, interval=0.01)