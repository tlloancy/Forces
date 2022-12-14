using System;
using System.Runtime.InteropServices;
using UnityEngine;
using LostPolygon.System.Net;
using LostPolygon.System.Net.Sockets;

namespace LostPolygon.Examples {
    public static class SocketExamplesTools {
        public static bool IsRuntimePlatformMobile() {
            return Application.platform == RuntimePlatform.Android
                   || Application.platform == RuntimePlatform.IPhonePlayer
               #if !UNITY_4_0 && !UNITY_4_1
            || Application.platform == RuntimePlatform.WP8Player 
               #endif
                ;
        }

        public static float UpdateScaleMobile(float baseHeight, float baseWidth) {
            if (!IsRuntimePlatformMobile())
                return 1f;

            float scaleFactor = Mathf.Max(Mathf.Min(Screen.width / baseWidth, Screen.height / baseHeight) * 0.94f, 1f);

            Vector3 scale;
            scale.x = scaleFactor;
            scale.y = scaleFactor;
            scale.z = 1f;

            GUI.matrix = Matrix4x4.TRS(Vector3.zero, Quaternion.identity, scale);

            return scaleFactor;
        }

        public static void TouchScroll(ref Vector2 scrollPosition) {
            if (Input.touchCount > 0) {
                Touch touch = Input.touches[0];
                if (touch.phase == TouchPhase.Moved) {
                    scrollPosition.y += touch.deltaPosition.y; 
                    scrollPosition.y = Mathf.Max(0f, scrollPosition.y);
                }
            }
        }

        public static IPAddress GetHostIpAddress(string host) {
            IPAddress[] addressList = Dns.GetHostAddresses(host);
            foreach (IPAddress address in addressList) {
                if (address.AddressFamily == AddressFamily.InterNetwork)
                    return address;
            }

            return null;
        }
    }
}
